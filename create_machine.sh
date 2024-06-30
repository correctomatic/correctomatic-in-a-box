# Define variables
VM_NAME="ansible-docker-vm"
BASE_VM_NAME="base-ubuntu-server"
NEW_HDD_PATH="path/to/new/hdd.vdi"
BASE_HDD_PATH="path/to/base/hdd.vdi"
MEMORY="2048"
CPUS="2"

# Create a new VM
VBoxManage createvm --name $VM_NAME --ostype Ubuntu_64 --register

# Set memory and CPUs
VBoxManage modifyvm $VM_NAME --memory $MEMORY --cpus $CPUS

# Create a new HDD by copying the base HDD
VBoxManage clonehd $BASE_HDD_PATH $NEW_HDD_PATH --format VDI

# Attach the new HDD to the VM
VBoxManage storagectl $VM_NAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $VM_NAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $NEW_HDD_PATH

# Add a network adapter
VBoxManage modifyvm $VM_NAME --nic1 natnetwork --nat-network1 "NatNetwork" --cableconnected1 on

# Setup port forwarding for SSH
VBoxManage modifyvm $VM_NAME --natpf1 "guestssh,tcp,,2222,,22"

# Create a virtual optical disk file (ISO) and attach it to the VM
VBoxManage storagectl $VM_NAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $VM_NAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium emptydrive
