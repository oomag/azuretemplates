#!/bin/sh
disks=`find /dev -type b -regex '.*sd\([c-z]\|[a-z][a-z]\)' 2>/dev/null | tr '\n' ' '`
pvcreate $disks
vgcreate vol_data $disks
lvcreate --extents 100%FREE --stripes 32 --stripesize 256 --name root vol_data
mkfs.xfs /dev/mapper/vol_data-root
mkdir /data
mount /dev/mapper/vol_data-root /data/
chmod 777 -R /data

echo /dev/mapper/vol_data-root /data xfs defaults 0 0 >> /etc/fstab

yum -y install nfs-utils
systemctl enable nfs-server.service
systemctl start nfs-server.service

# $1 is a network prefix for given machine
echo "/data/ ${1}(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a

echo '1 eth1
2 eth2
3 eth3
4 eth4
5 eth5
6 eth6
7 eth7
' >> /etc/iproute2/rt_tables

echo '#!/bin/sh
ip route add default via 10.0.0.101 dev eth1 table eth1
ip route add default via 10.0.0.102 dev eth2 table eth2
ip route add default via 10.0.0.103 dev eth3 table eth3
ip route add default via 10.0.0.104 dev eth4 table eth4
ip route add default via 10.0.0.105 dev eth5 table eth5
ip route add default via 10.0.0.106 dev eth6 table eth6
ip route add default via 10.0.0.107 dev eth7 table eth7

ip rule add from 10.0.0.101 table eth1
ip rule add from 10.0.0.102 table eth2
ip rule add from 10.0.0.103 table eth3
ip rule add from 10.0.0.104 table eth4
ip rule add from 10.0.0.105 table eth5
ip rule add from 10.0.0.106 table eth6
ip rule add from 10.0.0.107 table eth7
exit 0' > /etc/rc.local
