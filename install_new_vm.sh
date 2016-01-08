#!/bin/bash
# Script to install a new VM from a "CentOS 7 (64-bit) template"
# Must be run as root
# Tested on Xen Server 6.1

set -e

for i in "$@"
do
case $i in
    -h=*|--host_name=*)
    HOST_NAME="${i#*=}"
    shift 
    ;;
    -m=*|--vm_memory=*)
    VM_MEMORY="${i#*=}"
    shift 
    ;;
    -c=*|--cpu_count=*)
    VM_CPU_COUNT="${i#*=}"
    shift 
    ;;
    -d=*|--disk_size=*)
    VM_DISK_SIZE="$((${i#*=} * 1073741824))"
    shift
    ;;
    -n=*|--network_name=*)
    NETWORK="${i#*=}"
    shift
    ;;
    *)
            # unknown option
    ;;
esac
done

echo "VM hostname: ${HOST_NAME}" 
echo "Memory GB: ${VM_MEMORY}"
echo "CPU count: ${VM_CPU_COUNT}"
echo "Disk size GB: ${VM_DISK_SIZE}"
echo "Network: ${NETWORK}"

LOCAL_STORAGE_UUID=$(xe sr-list name-label="Local storage" |grep uuid | awk '{print $5}')

#Install a new VM
xe vm-install template="CentOS 7 (64-bit) template" new-name-label="${HOST_NAME}" sr-name-label="Local storage"
VM_UUID=$(xe vm-list name-label="${HOST_NAME}" | grep uuid | awk '{print $5}')

#Add a network interface
NETWORK_UUID=$(xe network-list name-label="${NETWORK}" |grep uuid | awk '{print $5}')
xe vif-create vm-uuid="${VM_UUID}" network-uuid="${NETWORK_UUID}" device=0

#Change memory settings
xe vm-memory-limits-set dynamic-max=${VM_MEMORY}GiB dynamic-min=${VM_MEMORY}GiB static-max=${VM_MEMORY}GiB static-min=${VM_MEMORY}GiB uuid="${VM_UUID}" 

#Change CPU settings
xe vm-param-set VCPUs-max=${VM_CPU_COUNT} uuid="${VM_UUID}"
xe vm-param-set VCPUs-at-startup=${VM_CPU_COUNT} uuid="${VM_UUID}"

#Add a new disk

#create a new VDI
VDI_UUID=$(xe vdi-create sr-uuid="${LOCAL_STORAGE_UUID}" name-label="new disk for ${HOST_NAME}" type=user  virtual-size=${VM_DISK_SIZE})

#Create the Virtual Block Device (VBD) that connects the VDI to the VM
VBD_UUID=$(xe vbd-create vm-uuid="${VM_UUID}" device=1 vdi-uuid="${VDI_UUID}" bootable=false mode=RW type=Disk)
#xe vbd-plug uuid="${VBD_UUID}"

xe vm-start vm="${HOST_NAME}"
