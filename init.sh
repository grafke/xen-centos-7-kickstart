#!/bin/bash

for i in "$@"
do
case $i in
    -h=*|--host_name=*)
    HOST_NAME="${i#*=}"
    shift 
    ;;
    -n=*|--net_addr=*)
    NETWORK_ADDRESS="${i#*=}"
    shift 
    ;;
     -sn=*|--sec_net_addr=*)
    SEC_NETWORK_ADDRESS="${i#*=}"
    shift
    ;;
    -u=*|--user=*)
    USER="${i#*=}"
    shift
    ;;
    *)
            # unknown option
    ;;
esac
done

#change the hostname
hostnamectl set-hostname ${HOST_NAME}

#format the second disk
mkfs.ext4 -m0 /dev/xvdb > /dev/null

#create a new user
userdel centos > /dev/null
useradd ${USER} > /dev/null
echo changeit | passwd ${USER} --stdin

#add the new user to sudoers
echo "${USER}	ALL=(ALL) 	ALL" >> /etc/sudoers

#update the IP address
sed -i "s/IPADDR=.*/IPADDR=${NETWORK_ADDRESS}/g" /etc/sysconfig/network-scripts/ifcfg-eth0

#update the secondary IP address

cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0:0
sed -i "s/IPADDR=192.*/IPADDR=${SEC_NETWORK_ADDRESS}/g" /etc/sysconfig/network-scripts/ifcfg-eth0:0
sed -i '/^DEVICE/ s/$/:0/' /etc/sysconfig/network-scripts/ifcfg-eth0:0
sed -i '/DNS1/d' /etc/sysconfig/network-scripts/ifcfg-eth0:0
sed -i '/GATEWAY/d' /etc/sysconfig/network-scripts/ifcfg-eth0:0

echo "New VM has been created."
echo "Hostname: ${HOST_NAME}"
echo "New IP addresses: ${NETWORK_ADDRESS} ${SEC_NETWORK_ADDRESS}"
echo "Username: ${USER}"
echo "Password: changeit"
echo "Insert the following line to /etc/fstab. Update the <destination>"
echo "/dev/xvdb <destination>                   ext4    defaults        1 1"

reboot


