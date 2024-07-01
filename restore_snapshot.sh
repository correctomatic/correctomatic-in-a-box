#!/bin/bash

VM_NAME="correctomatic_vps"
SNAPSHOT_NAME="clean_state"

# Stop the VM if it's running
VBoxManage controlvm "$VM_NAME" poweroff

# Restore the snapshot
VBoxManage snapshot "$VM_NAME" restore "$SNAPSHOT_NAME"

# Start the VM
VBoxManage startvm "$VM_NAME" # --type headless
