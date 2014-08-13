import sys

output = sys.stdin.read()
lines = output.split("\n")

for line in lines:
    if "OS-EXT-SRV-ATTR:instance_name" in line:
        print line.strip()
        print line.strip().split("|")[2].split(" ")[1]

