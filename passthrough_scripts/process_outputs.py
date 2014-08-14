#! usr/bin/python
"""
process_outputs.

This script performs several string manipulation operations as directed to by
instance_master.sh in order to take the output of shell commands and extract
and return data.

"""
import sys
import argparse

# Command Line Options
parser = argparse.ArgumentParser(description="Work With Command Outputs \
                                 to Assist With Automated PCI Passthrough")
parser.add_argument('--ip', default=None, action='store',
                    help="Instance IP Address")
parser.add_argument('--ifconfig', default=False, action='store_true',
                    help="Flag to Indicate IP Address Desired from ifconfig")
parser.add_argument('--virsh_name', default=None, action='store_true',
                    help="Flag to Indicate Virsh Name Desired")
parser.add_argument('--pci_name', default=None, action='store_true',
                    help="Flag to Indicate PCI Card Name Desired")
parser.add_argument('--xml', default=None, action='store_true',
                    help="Flag to Indicate XML String Desired")

args = parser.parse_args()
output = sys.stdin.read()

# Lookup nova name by IP in output from nova list.
if args.ip:
    lines = output.split("\n")
    for line in lines:
        if args.ip in line:
            print line.split(" ")[1]
            break

# Extract IP address from ifconfig output. 
elif args.ifconfig:
    lines = output.split("\n")
    for i in range(len(lines)):
        if "eth0" in lines[i]:
            print lines[i + 1].strip().split("inet addr:")[1].split(" ")[0]

# Extract virsh name from nova show output.
elif args.virsh_name:
    lines = output.split("\n")
    for line in lines:
        if "OS-EXT-SRV-ATTR:instance_name" in line:
            print line.strip().split("|")[2].split(" ")[1]

# Restructure lspci output to give PCI card name recognizable by virsh.
elif args.pci_name:
    lines = output.split("\n")
    card_name = lines[0].split(" ")[0]
    result = "pci_0000_"
    for char in card_name:
        if char in [":", "."]:
            result += "_"
        else:
            result += char
    print result

# Generate XML snippet to be injected into device attachment configuration.
elif args.xml:
    tokens = output.split("_")
    xml = "<address domain='0x0000' bus='0x{0}' slot='0x{1}' function='0x{2}'/>"
    xml = xml.format(tokens[2], tokens[3], tokens[4])
    print xml
