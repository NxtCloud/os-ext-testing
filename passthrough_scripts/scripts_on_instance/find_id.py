import sys
import argparse 

parser = argparse.ArgumentParser(description="Find Instance's Virsh Name \
    from Given IP")

parser.add_argument('--ip', default=False, action='store',
                    help="Instance IP Address")

args = parser.parse_args()

output = sys.stdin.read()
lines = output.split("\n")

for line in lines:
    if args.ip in line:
        print line.split(" ")[1]
        break
