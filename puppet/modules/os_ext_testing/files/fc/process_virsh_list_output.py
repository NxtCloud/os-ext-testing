#! /usr/bin/python
"""
process_virsh_list_output.py

A simple script to extract the ID of the virtual machine currently running (for
Fibre Channel testing purposes there should only be one) from the output of the
virsh list command.

This should be placed on the blade.
"""
import sys

print  sys.stdin.read().split('\n')[2].strip().split(" ")[0]



