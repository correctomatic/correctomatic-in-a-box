## TO-DO

registry service:
  - nginx: proxypass to container
  - Configure let's encrypt
  - Create users for the registry service


## Run playbook

ansible-playbook playbook.yml

ansible-playbook -i a_different_hosts_file playbook.yml


## Redis insights

This will work only when testing in local, 

Create volume for persisting connections:
`docker volume create redisinsight`

Warning, the container is running in host's network, be careful with this:
`docker run --rm --name redis_insight -v redisinsight:/data --network host redis/redisinsight`

http://localhost:5540/

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


Debug tools:
net-tools

## Certbot

**When testing the playbook, you need to redirect the domain to the virtual machine.**

https://serverfault.com/questions/750902/how-to-use-lets-encrypt-dns-01-challenge-validation


certbot -d bristol3.pki.enigmabridge.com --manual --preferred-challenges dns certonly

certbot --text --agree-tos --email you@example.com -d bristol3.pki.enigmabridge.com --manual --preferred-challenges dns --expand --renew-by-default  --manual-public-ip-logging-ok certonly



## Slow tasks
- Install docker, extremly slow
- Install certbot, slow
