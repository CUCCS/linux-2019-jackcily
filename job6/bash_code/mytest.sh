#!/bin/bash

source vars.sh
$KNOWN_HOSTS="/home/xhl/.ssh/known_hosts"
if [ -d "$KNOWN_HOSTS" ] ; then
  rm $KNOWN_HOSTS
  #echo "dede\n\n\n"
fi

expect ssh-root.sh $ip $username $password ${keypath}

ssh $username@$ip 'bash -s' < apt-ins.sh


#修改配置文件
echo -e "\n\n使用 sed 修改配置文件\n\n"
sed -i "s/WHITE_IP/${WHITE_IP}/g"  /mnt/share/configs/proftpd.conf

sed -i "s/CLIENT_IP/${CLIENT_IP}/g"  /mnt/share/configs/exports

sed -i "s/SMB_USER/${SMB_USER}/g"  /mnt/share/configs/smb.conf
sed -i "s/SMB_GROUP/${SMB_GROUP}/g"  /mnt/share/configs/smb.conf

sed -i "s/DHCP_INTERFACE/${DHCP_INTERFACE}/g"  /mnt/share/configs/isc-dhcp-server

sed -i "s/SUBNET/${SUBNET}/g"  /mnt/share/configs/dhcpd.conf
sed -i "s/SUB_DOWN/${SUB_DOWN}/g"  /mnt/share/configs/dhcpd.conf
sed -i "s/SUB_TOP/${SUB_TOP}/g"  /mnt/share/configs/dhcpd.conf
sed -i "s/SUB_BROADCAST/${SUB_BROADCAST}/g"  /mnt/share/configs/dhcpd.conf

sed -i "s/INTERFACE_ADDRESS/${INTERFACE_ADDRESS}/g" /mnt/share/configs/db.cuc.edu.cn


#将文件复制到被安装
echo -e "\n\n复制配置文件\n\n"
scp  /mnt/share/configs/proftpd.conf $username@$ip:/etc/proftpd/
scp  /mnt/share/configs/exports  $username@$ip:/etc/
scp  /mnt/share/configs/smb.conf $username@$ip:/etc/samba/
scp  /mnt/share/configs/isc-dhcp-server $username@$ip:/etc/default/
scp  /mnt/share/configs/dhcpd.conf $username@$ip:/etc/dhcp/
scp  /mnt/share/configs/db.cuc.edu.cn $username@$ip:/etc/bind/
scp vars.sh $username@$ip:

ssh $username@$ip 'bash -s' < action.sh
