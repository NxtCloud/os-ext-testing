PCI_CARD=pci_0000_05_00_2
INSTANCE=$(virsh list | python process_virsh_list_output.py)
virsh nodedev-dettach $PCI_CARD
virsh attach-device $INSTANCE fcoe.xml
