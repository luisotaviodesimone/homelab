#!/bin/bash

vmId=$1

if [ -z "$vmId" ]; then
  echo "Usage: $0 <vmId>"
  exit 1
fi

qm clone 8000 $vmId --name ubuntu-master-01
qm set $vmId --cicustom "user=local:snippets/user.yaml,network=local:snippets/network.yaml"
qm start $vmId

