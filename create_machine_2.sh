# Define variables
BASE_VM_NAME="base-ubuntu-server"
NEW_VM_NAME="ansible-docker-vm"
NEW_HDD_PATH="path/to/new/hdd.vdi"
BASE_HDD_PATH="path/to/base/hdd.vdi"
MEMORY="2048"
CPUS="2"

# Clone the base VM
VBoxManage clonevm $BASE_VM_NAME --name $NEW_VM_NAME --register --mode all --options keepallmacs

# Clone the base HDD
VBoxManage clonehd $BASE_HDD_PATH $NEW_HDD_PATH --format VDI

# Attach the new HDD to the new VM
VBoxManage storageattach $NEW_VM_NAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $NEW_HDD_PATH

# Configure the network to use Bridged Adapter
VBoxManage modifyvm $NEW_VM_NAME --nic1 bridged --bridgeadapter1 "your_network_interface"

# Start the VM
VBoxManage startvm $NEW_VM_NAME --type headless

ssh vagrant@<new_vm_ip>
sudo nano /etc/netplan/01-netcfg.yaml

network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]


sudo netplan apply

