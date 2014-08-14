#! /usr/bin/env bash

# "instance_master/sh" combines shell commands and Python scripts to extract a
# chain of data in order to finally pass to another script the information it
# needs to successfully pass through a Fibre Channel PCI Card to the virtual
# machine this script is running on. The instance only knows its IP address,
# while its Virsh name is required for pass through. This script uses Nova on
# the provider blade as an intermediary to find the name. Meanwhile, this
# script finds the Fibre Channel PCI card on the provider and generates the
# information Virsh needs to attach it.

PROVIDER=stack@10.50.137.2 # Example

# Finding local IP leads to Nova ID leads to virsh name.

IP=$(ifconfig | python process_outputs.py --ifconfig)
echo "Node IP is $IP"

ID=$(ssh $PROVIDER 'source devstack/openrc admin admin && nova list' | python process_outputs.py --ip $IP)
echo "Node ID is $ID"

VIRSH_NAME=$(ssh $PROVIDER 'source devstack/openrc admin admin && nova show $ID' | process_outputs.py --virsh_name)
echo "Node's virsh name is $VIRSH_NAME"

# Discover PCI card and generate XML and sed snippets to allow attachment.

PCI_CARD=$(ssh $PROVIDER 'lspci | grep "Fibre Channel"' | python process_outputs.py --pci)
echo "PCI card being passed through is $PCI_CARD"

XML=$(echo $PCI_CARD | python process_outputs.py --xml)
CMD="sed -i s,<address domain='0x0000' bus='0x5' slot='0x00' function='0x2'/>,"$XML",g passthrough_temp/fcoe.xml"

# Put passthrough script and data onto provider and update data.

ssh $PROVIDER 'mkdir passthrough_temp'
scp fcoe.xml $PROVIDER:~/passthrough_temp
ssh $PROVIDER '$CMD'

# Run passthrough script and clean up.

ssh $PROVIDER "rm -r passthrough_temp"
