import sys

output = sys.stdin.read()

lines = output.split("\n")

for i in range(len(lines)):
    if "eth0" in lines[i]:
        print lines[i+1].strip().split("inet addr:")[1].split(" ")[0]
