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


## Test registry

Test that registry works:
```bash
curl --insecure -X GET https://$REGISTRY_DOMAIN:5000/v2/_catalog
```

### Prepare your local machine to work with the registry

Docker needs to trust the self-signed certificate used by the virtual machine. You won't need this in production because you will have a real certificate.

```bash
REGISTRY_DOMAIN=registry.correctomatic.alvaromaceda.es

sudo mkdir -p /etc/docker/certs.d/$REGISTRY_DOMAIN

openssl s_client -showcerts -connect $REGISTRY_DOMAIN:443 </dev/null 2>/dev/null | openssl x509 -outform PEM > /tmp/$REGISTRY_DOMAIN.crt

sudo cp /tmp/$REGISTRY_DOMAIN.crt /etc/docker/certs.d/$REGISTRY_DOMAIN/








sudo mkdir -p /etc/docker/certs.d/registry.correctomatic.alvaromaceda.es

openssl s_client -showcerts -connect registry.correctomatic.alvaromaceda.es:443 </dev/null 2>/dev/null | openssl x509 -outform PEM > /etc/docker/certs.d/registry.correctomatic.alvaromaceda.es/

sudo cp registry.correctomatic.alvaromaceda.es.crt /etc/docker/certs.d/registry.correctomatic.alvaromaceda.es/





REGISTRY_DOMAIN=registry.correctomatic.alvaromaceda.es

openssl s_client -showcerts -connect registry.correctomatic.alvaromaceda.es:443 </dev/null 2>/dev/null | openssl x509 -outform PEM > registry.correctomatic.alvaromaceda.es.crt




docker manifest inspect registry.correctomatic.alvaromaceda.es/banana
docker login --insecure-registry=registry.correctomatic.alvaromaceda.es


Prepare certificates in your dev machine:

1) Copy the certificates to your dev machine





mkdir -p /etc/docker/certs.d/$REGISTRY_DOMAIN:5000
scp ansible@correctomatic_vps:/etc/letsencrypt/live/$REGISTRY_DOMAIN/fullchain.pem /tmp/correctomatic_registry.crt

mkdir -p /etc/docker/certs.d/registry.local.doc:5000/ca.crt
sudo cp tls.crt /etc/docker/certs.d/registry.local.doc:5000/ca.crt


sudo mkdir certs.d


openssl x509 -outform der -in certificate.pem -out certificate.der

You will need to copy the certificate to the client machine, and add it to the docker configuration:
sudo cp registry.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
sudo systemctl restart docker

scp <username>@<docker_host_ip>:/path/to/certificates/fullchain.pem /path/on/your/local/machine/

$mkdir -p /etc/docker/certs.d/ip_address:5000
$cp docker_reg_certs/domain.crt /etc/docker/certs.d/ip_address:5000/ca.crt
$cp docker_reg_certs/domain.crt /usr/local/share/ca-certificates/ca.crt
$update-ca-certificates


https://stackoverflow.com/questions/74727327/insecure-docker-registry-and-self-signed-certificates

When you using self-sign cert registry, you have two way to pull image from there.

1) Add { "insecure-registries" : ["registry.local.doc:5000"] } to /etc/docker/daemon.json

2) Add your self-sign cert to trust store on every woker. This way don't require restart k3s. For ubuntu see below.

sudo cp tls.crt /usr/local/share/ca-certificates
sudo update-ca-certificates

3) add cert to docker certs folder

Instruct every Docker daemon to trust that certificate. The way to do this depends on your OS.
Linux: Copy the domain.crt file to /etc/docker/certs.d/myregistrydomain.com:5000/ca.crt on every Docker host. You do not need to restart Docker.

sudo cp tls.crt /etc/docker/certs.d/registry.local.doc:5000/ca.crt


/etc/letsencrypt/live/registry.correctomatic.alvaromaceda.es/fullchain.pem
