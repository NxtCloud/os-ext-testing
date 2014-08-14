#! /usr/bin/env bash

# "passthrough.sh" is a script that takes an instance's Virsh name and a PCI
# card name and passes through the card to the instance.

# Data received from instance_master.sh
INSTANCE=$1
PCI_CARD=$2

virsh nodedev-dettach $PCI_CARD
virsh attach-device $INSTANCE fcoe.xml
