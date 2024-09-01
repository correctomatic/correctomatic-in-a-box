## TO-DO

- Configure the VPS to access its own registry
- Runner containers
- API container
- APP container


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


cat ~/.ssh/id_ansible.pub | ssh ansible@correctomatic_vps 'cat >> ~/.ssh/authorized_keys'

You can also use a host only network and a nat network:

network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 10.10.10.10/24
      routes:
        - to: default
          via: 10.10.10.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.56.56/24

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


### Registry notes

openssl passwd -apr1 -salt N2Kx8OeF pass1

user1:$apr1$2T2gZjCU$w/yvTwnIlGboHjY45BL3C0
user2:$apr1$gh4CrWNs$lCepmELnNvJHD24YDxfIv/
user3:$apr1$.W/QG0N9$oI824dpbk7KscaWWd/iu9.


Registry configuration:
https://distribution.github.io/distribution/about/configuration/


https://phoenixnap.com/kb/set-up-a-private-docker-registry


**Check this:**
https://distribution.github.io/distribution/about/deploying/
Pull the ubuntu:16.04 image from Docker Hub.

$ docker pull ubuntu:16.04
Tag the image as localhost:5000/my-ubuntu. This creates an additional tag for the existing image. When the first part of the tag is a hostname and port, Docker interprets this as the location of a registry, when pushing.

$ docker tag ubuntu:16.04 localhost:5000/my-ubuntu
Push the image to the local registry running at localhost:5000:

$ docker push localhost:5000/my-ubuntu
Remove the locally-cached ubuntu:16.04 and localhost:5000/my-ubuntu images, so that you can test pulling the image from your registry. This does not remove the localhost:5000/my-ubuntu image from your registry.

$ docker image remove ubuntu:16.04
$ docker image remove localhost:5000/my-ubuntu
Pull the localhost:5000/my-ubuntu image from your local registry.

$ docker pull localhost:5000/my-ubuntu


```bash
REGISTRY_DOMAIN=registry.correctomatic.alvaromaceda.es

docker pull alpine:latest
docker tag alpine:latest $REGISTRY_DOMAIN/my-test

docker login $REGISTRY_DOMAIN
docker push $REGISTRY_DOMAIN/my-test
docker pull $REGISTRY_DOMAIN/my-test
```



Tests in local:
-----------------------

docker run --rm -p 5000:5000 -e REGISTRY_HTTP_SECRET=banana registry:latest
docker run --rm -p 5000:5000 --name docker_registry_2 -e REGISTRY_HTTP_SECRET=banana registry:latest

REGISTRY_DOMAIN=localhost:5000
REGISTRY_DOMAIN=registry.correctomatic.alvaromaceda.es
REGISTRY_DOMAIN=registry.correctomatic.alvaromaceda.es:5000

docker tag alpine:latest $REGISTRY_DOMAIN/my-test

docker login $REGISTRY_DOMAIN
docker push $REGISTRY_DOMAIN/my-test
docker pull $REGISTRY_DOMAIN/my-test


https://serverfault.com/questions/911360/docker-nginx-reverse-proxy-configuration


- Sólo falla el push, el pull funciona
- Si se hace en local contra localhost:5000 funciona


## Info about the API

"repos" are the images

Get images: /v2/_catalog
Get tags of a image: /v2/:repo/tags/list

Delete images from registry:
https://stackoverflow.com/questions/25436742/how-to-delete-images-from-a-private-docker-registry
https://azizunsal.github.io/blog/post/delete-images-from-private-docker-registry/

CHECK THIS FOR THE REGISTRY:
https://medium.com/@haminhsang1903/private-docker-registry-with-https-and-a-nginx-reverse-proxy-using-docker-compose-6c1335c5e820

      REGISTRY_HTTP_ADDR: 0.0.0.0:5000
      REGISTRY_HTTP_TLS_CERTIFICATE: /certs/domain.crt
      REGISTRY_HTTP_TLS_KEY: /certs/domain.key


## Inspection tools


## Prepare VPS

Copy-paste for preparing the VPS:

```bash

ssh -o PreferredAuthentications=password  ubuntu@teapot.correctomatic.org
sudo useradd -m -G adm,cdrom,sudo,dip,lxd -s /bin/bash -p $(openssl passwd -1) ansible
sudo useradd -m -G adm,cdrom,sudo,dip,lxd -s /bin/bash -p $(openssl passwd -1) alvaro

ssh-copy-id -o PreferredAuthentications=password -i ~/.ssh/id_teapot_alvaro.pub alvaro@teapot.correctomatic.org
ssh-copy-id -o PreferredAuthentications=password -i ~/.ssh/id_teapot_ansible.pub ansible@teapot.correctomatic.org



Host teapot_ansible
	Hostname	teapot.correctomatic.org
	User		ansible
	PreferredAuthentications publickey
	IdentityFile	~/.ssh/id_teapot_ansible
	IdentitiesOnly	yes
Host teapot
	Hostname	teapot.correctomatic.org
	User		alvaro
	PreferredAuthentications publickey
	IdentityFile	~/.ssh/id_teapot_alvaro
	IdentitiesOnly	yes

ssh teapot
sudo userdel -r ubuntu

```
