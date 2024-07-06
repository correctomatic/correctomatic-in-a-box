## TO-DO

registry service:
  - Create users for the registry service
  - Bind htpasswd file
  - Bind mount volume for storing the data
  - Check the blob error


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
REGISTRY_DOMAIN=registry.correctomatic.alvaromaceda.es
curl --insecure -X GET https://$REGISTRY_DOMAIN/v2/_catalog
```

### Prepare your local machine to work with the registry

Docker needs to trust the self-signed certificate used by the virtual machine. You won't need this in production because you will have a real certificate.
**YOU MUST DO THIS EACH TIME THE CERTIFICATES ARE GENERATED**

```bash
REGISTRY_DOMAIN=registry.correctomatic.alvaromaceda.es

sudo mkdir -p /etc/docker/certs.d/$REGISTRY_DOMAIN

openssl s_client -showcerts -connect $REGISTRY_DOMAIN:443 </dev/null 2>/dev/null | openssl x509 -outform PEM > /tmp/$REGISTRY_DOMAIN.crt

sudo cp /tmp/$REGISTRY_DOMAIN.crt /etc/docker/certs.d/$REGISTRY_DOMAIN/
```

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
