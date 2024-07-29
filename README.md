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

2) Configure the network. You will need to have two networks:
   - One NAT network, so the VPS can connect to the internet
   - One host only network so you can use the VPS from your host

   Folow this steps:
   1) Create a NAT network using the VirtualBox network manager. Assign the `10.10.10.0/24` address to the network, the virtual machine will have the address `10.10.10.10`.
   2) Create a host only network using the VirtualBox network manager. The address will be 192.168.56.1/24. You don't need to have the DHCP enabled.
   3) Configure the interfaces in the virtual machine.
      1) Add two network interfaces: the first will be connected to the NAT network, and the second to the host only network.
      2) Create the file `/etc/netplan/01-netcfg.yaml` with this content (adapt the nameservers to your network settings):

```yaml
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
```

Alternatively, you can use a bridged network. In that case, you will need to assign a fixed IP to the virtual machine, either by configuring the DHCP of the network or by modifying the netplan.

3) Generate a ssh key
```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_ansible -C "ansible@correctomatic_vps"
```

4) Copy the key to the VPS
```sh
ssh-copy-id -i id_ansible ansible@correctomatic_vps
```

At this point, create a snapshot and name it `clean_state`. You can restore this snapshot later to retry the ansible playbook with a clean machine. There is a script, `restore_snapshot.sh`, for restoring that snapshot automatically.

