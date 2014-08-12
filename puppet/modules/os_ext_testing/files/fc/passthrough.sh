#This needs to go on the blade.
#Do lspci | grep -i fc to see which pci card has fc. e.g.
# lspci | grep -i fc
# 05:00.2 Fibre Channel: Emulex Corporation OneConnect 10Gb FCoE Initiator (be3) (rev 01)
# 05:00.3 Fibre Channel: Emulex Corporation OneConnect 10Gb FCoE Initiator (be3) (rev 01)


PCI_CARD=pci_0000_05_00_2
INSTANCE=$(virsh list | python process_virsh_list_output.py)
virsh nodedev-dettach $PCI_CARD
virsh attach-device $INSTANCE fcoe.xml

