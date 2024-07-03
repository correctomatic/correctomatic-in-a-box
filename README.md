
## Run playbook

ansible-playbook -i hosts playbook.yml


## Secrets

echo "ansible_become_password: ansible" > secrets/sudo_password.yml

Encrypt, optional for now:
ansible-vault encrypt secrets/sudo_password.yml

ansible-playbook -i hosts your_playbook.yml --ask-vault-pass
ansible-playbook -i hosts your_playbook.yml --vault-password-file ~/.vault_pass.txt

## Configure virtual machine

correctomatic_vps in hosts file

ssh-copy-id -i id_ansible ansible@correctomatic_vps

ssh -i id_ansible ansible@192.168.3.111

sudo nano /etc/netplan/01-netcfg.yaml


network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 192.168.3.111/24
      routes:
        - to: default
          via: 192.168.3.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4


cat ~/.ssh/id_ansible.pub | ssh ansible@10.0.2.15 'cat >> ~/.ssh/authorized_keys'

## Install ansible

sudo apt-get install libyaml-dev

sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

## Testing with virtual box

You need an already installed VBox installation

./create_machine.sh


VBoxManage startvm $VM_NAME --type headless
ssh -p 2222 vagrant@localhost



### Redis server

https://github.com/jprichardson/ansible-redis

https://github.com/geerlingguy/ansible-role-redis


