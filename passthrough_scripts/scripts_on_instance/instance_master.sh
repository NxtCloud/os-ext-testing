PROVIDER=stack@10.50.148.1 # Example
export OS_USERNAME=admin
export OS_PASSWORD=hp**
IP=$(ifconfig | python find_ip.py)
ID=$(ssh $PROVIDER 'source devstack/openrc admin admin && nova list' | python find_id.py --ip $IP)
VIRSH_NAME=$(ssh $PROVIDER 'nova show $ID' | find_virsh_name.py)
ssh PROVIDER "./passthrough.sh $VIRSH_NAME"
