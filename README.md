# Correctomatic Ansible VPS playbook

The purpose of this repository is to provide a simple way to install the Correctomatic in a single VPS server, to have a cheap working version of the system. The playbook will install in the VPS:

- Docker
- A Docker registry
- Nginx acting as a reverse proxy for the registry
- A Redis server
- PENGING: the correctomatic processes

If you want to install the Correctomatic in multiple servers, you could probably reuse the roles defined in this playbook

## Running the playbook

TO-DO

### Configuration

TO-DO

## Development

TO-DO

### Prepare your host

TO-DO: /etc/hosts entries

### Prepare the virtual host

1) Install an Ubuntu 22.04 server. The playbook expects a user `ansible` with password ansible (you can change the password modifying `secrets/sudo_password.yml`)

2) Generate a ssh key
```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_ansible -C "ansible@correctomatic_vps"
```
3) Copy the key to the VPS
```sh
ssh-copy-id -i id_ansible ansible@correctomatic_vps
```
4) Configure the network. You will need to have two networks:
   - One NAT network, so the VPS can connect to the internet
   - One host only network so you can use the VPS from your host




At this point, create a snapshot and name it `clean_state`. You can restore this snapshot later to retry the ansible playbook with a clean machine. There is a script, `restore_snapshot.sh`, for restoring that snapshot automatically.

