#!/bin/bash -xe

# Copyright (C) 2014 Hewlett-Packard Development Company, L.P.
#    All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.

HOSTNAME=$1
SUDO='true'
THIN='true'
PYTHON3='false'
PYPY='false'
ALL_MYSQL_PRIVS='true'
GIT_BASE=http://git.openstack.org

export http_proxy=$NODEPOOL_HTTP_PROXY
export https_proxy=$NODEPOOL_HTTPS_PROXY
export no_proxy=$NODEPOOL_NO_PROXY

TEMPFILE=`mktemp`
echo "Acquire::http::Proxy \"$http_proxy\";" >> $TEMPFILE
chmod 0444 $TEMPFILE
sudo chown root:root $TEMPFILE
sudo mv $TEMPFILE /etc/apt/apt.conf

TEMPFILE=`mktemp`
echo "Defaults env_keep += \"no_proxy http_proxy https_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY\"" >> $TEMPFILE
chmod 0440 $TEMPFILE
sudo chown root:root $TEMPFILE
sudo mv $TEMPFILE /etc/sudoers.d/60_keep_proxy_settings

sudo visudo -c

TEMPFILE=`mktemp`
echo "export http_proxy=$http_proxy
export https_proxy=$http_proxy
export ftp_proxy=$http_proxy
export no_proxy=localhost,127.0.0.1,localaddress,.localdomain.com,$no_proxy" >> $TEMPFILE
chmod 0444 $TEMPFILE
sudo chown root:root $TEMPFILE
sudo chmod +x $TEMPFILE
sudo mv $TEMPFILE /etc/profile.d/set_http_proxy.sh

source /etc/profile.d/set_http_proxy.sh

# Setup proxy settings in the environment, used by jenkins jobs
echo "http_proxy=$http_proxy
https_proxy=$http_proxy
ftp_proxy=$http_proxy
no_proxy=localhost,127.0.0.1,localaddress,.localdomain.com,$no_proxy" | sudo tee -a /etc/environment

#Disable ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf


#Make sure the proxy settings are set, if not already
if [ -z $http_proxy ]; then
        export http_proxy=$http_proxy
        export https_proxy=$http_proxy
        export ftp_proxy=$http_proxy
        export no_proxy=localhost,127.0.0.1,localaddress,.localdomain.com,$no_proxy
fi

TEMPFILE=`mktemp`
echo "[global]
proxy = $http_proxy" >> $TEMPFILE
chmod 0444 $TEMPFILE
sudo chown root:root $TEMPFILE
mkdir -p ~/.pip/
sudo mv -f $TEMPFILE ~/.pip/pip.conf

#./prepare_node.sh "$HOSTNAME" "$SUDO" "$THIN" "$PYTHON3" "$PYPY" "$ALL_MYSQL_PRIVS" "$GIT_BASE"
./prepare_node_no_unbound.sh "$HOSTNAME" "$SUDO" "$THIN" "$PYTHON3" "$PYPY" "$ALL_MYSQL_PRIVS" "$GIT_BASE"

# While testing out the nodepool image creation, comment out the line below since it takes a long time.
#sudo -u jenkins -i /opt/nodepool-scripts/prepare_devstack.sh $HOSTNAME

./restrict_memory.sh

TEMPFILE=`mktemp`
echo "ssh-rsa
AAAAB3NzaC1yc2EAAAADAQABAAABAQCsR2h4V0uV2526Mxmdk0Agn10lCpXaMH7iTpksCUzzPQhRtXFfhBPNuWi51HpPouCGIbqUzMdsDvTvXwbig3/GWTThEpDMUv80e1HGYiGNXme3Z1bkIdPNKrARMZ+N6nYzoJKa4v4FMtEnt1u6gNoBcpOxq8GTGtehckL3TbTYWCrnjvutaKg0/ybPaw3xW2c7/4eUyHHKwqyGZtupFPP3dD9MPuWT4DO3M3uC6K6Jq04/DP5xr/CpI2yKBaDIkBDIE7tdZgZXOTm/USqUz+PZxiVMX3KEeQM9uoNFi/sI+7B8pnjyZ2n0zmerYDBW9HfOnL/DXqvhxnB9hsdwiyVh
stack@rahul-stack2" >> $TEMPFILE
chmod 0400 $TEMPFILE
sudo chown jenkins:jenkins $TEMPFILE
sudo cp $TEMPFILE /tmp/passthrough.pub
sudo mv -f $TEMPFILE /home/jenkins/passthrough.pub

TEMPFILE=`mktemp`
echo "-----BEGIN RSA PRIVATE KEY-----
MIIEpgIBAAKCAQEArEdoeFdLldudujMZnZNAIJ9dJQqV2jB+4k6ZLAlM8z0IUbVx
X4QTzbloudR6T6LghiG6lMzHbA70718G4oN/xlk04RKQzFL/NHtRxmIhjV5nt2dW
5CHTzSqwETGfjep2M6CSmuL+BTLRJ7dbuoDaAXKTsavBkxrXoXJC90202Fgq5477
rWioNP8mz2sN8VtnO/+HlMhxysKshmbbqRTz93Q/TD7lk+AztzN7guiuiatOPwz+
ca/wqSNsigWgyJAQyBO7XWYGVzk5v1EqlM/j2cYlTF9yhHkDPbqDRYv7CPuwfKZ4
8mdp9M5nq2AwVvR3zpy/w16r4cZwfYbHcIslYQIDAQABAoIBAQCfMXEA2rGWrZRn
Lbb628mDG5/HjauBLhTha/2wKnv3vCsGzeIQgAyIqk5ygTvwgLJ2X454121jlcKR
ur6y6w5UK7RoUm6I0BzQ0y9yYNVeO6EdYZlyPyvnRw3hJXipe8Fz3Wn7Q8u05AtP
ZuiVQ2Gvur9tiyfZlhExN1NYEG8PBY1+lKDdmBiu8XTbJ2jTg65+9p+4bhjDRaIX
MkKsal2jmSqrhyM/JHlCcRQ4xPxYF7RFJYRB0X3sgjSER3mjnQrVRfzPHE0Viis6
fiGUamXlxNt8rxKuOD/2INM6U91CNTPPwTrSCttbkGNC4r57nrG0HIgBu3GjNHj+
Gsd6mcKtAoGBANhEalTfjPWI8IJXwEYDBr7zz8cUCaC6x28AG7Jg5+6mlE31h1+H
CwQ5Mh4d+fC44bzVumwf7hBfEsOYGZMd80d1hjSUTX2cjLxEmyhUPUzqAYtEOswc
VfApXj4VUZ8B0M8mQmbigzKcjqxuA8+/rvy3/M2ogugGmo4i5QIVi8JjAoGBAMvu
HQ6330xkkJcH0ySl9jHHsqFFgl2eNfw/Y03HBhVB1KiyysnO3KqF/T6g9YjDShnq
TD7vTyhAFpC6pWuJgGGkjwOgDpHPYMFQ45H01jMNvHi23OLZ+UqS3fL4qPJq4PHp
rpLwJnF+Uiirkf+zNocNarGzfsnk6R4fAuPonWJrAoGBAJQwlRfhMuqQUhVOYc7X
hgjUchx8y3gaZEvYLCJXqrVp6Zdd1cwMce0L8B6Y9coQNYY6gYpTesI3E1l5YJTh
YfEmQ7bFpC+dVQYwkIza5EJO2o3+S7fO9sgg4JXz78Df8p/vHHL5ZWMJye23WN9C
/nnm7NBTVpf85mzc1kVOVDz3AoGBAKaztjMi4bmr93pOni42MIPO79nfXUs0GoNi
OcYJrJJR5wokZZsEq+QFddftceljYr6+hadorreDdC7JNJIsq7Kl93aKL37IHBrL
Ccx1bWf8kZXIPdZ/QsbQOfj1hf3smoeGc/uPro1WKskuP0Hb+PX7ZL1wsnNN2baS
uSUfMRCTAoGBAKu/q4aWcYoJ2O6yy7eNaAH9Tz6qRGe7PmK9hlumA0ah8/f3huIi
zS1V6L5THDUyrk4oYcBcCuqdO5JZRTH/IHQGuLDWZwEYkHJ9SHBAA0YyM/zMfCIz
FSRxtSGsdhYeRJi8xNuiDJ8eaBRP3WundLI2kdi0p2sxaJgvOVppR278
-----END RSA PRIVATE KEY-----" >> $TEMPFILE

chmod 0400 $TEMPFILE
sudo chown jenkins:jenkins $TEMPFILE
sudo cp $TEMPFILE /tmp/passthrough
sudo mv -f $TEMPFILE /home/jenkins/passthrough

