#!/bin/env bash

vmId=$1

if [ -z "$vmId" ]; then
  echo "Usage: $0 <vmId>"
  exit 1
fi

wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img -nc -P /var/lib/vz/images/

qm create $vmId --name "Ubuntu Noble Template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
qm set $vmId --scsi0 local-lvm:0,import-from=/var/lib/vz/images/noble-server-cloudimg-amd64.img
qm set $vmId --ide2 local-lvm:cloudinit
qm set $vmId --boot order=scsi0
qm set $vmId --serial0 socket --vga serial0
qm set $vmId --agent 1
qm set $vmId --onboot 1
qm resize $vmId scsi0 +38G
qm template $vmId
