# Correctomatic Ansible VPS playbook

The purpose of this repository is to provide a simple way to install the Correctomatic in a single VPS server, to have a cheap working version of the system. The playbook will install in the VPS:

- Docker
- A Docker registry
- Nginx acting as a reverse proxy for the registry
- A Redis server
- PENGING: the correctomatic processes

If you want to install the Correctomatic in multiple servers, you could probably reuse the roles defined in this playbook

## Configuration

The playbook **must** be configured modifying the `configuration/config.yml` file. The most important entries are:

- `development_mode`: should be `no` for production. If you want to run the playbook in development mode, follow the instructions in the corresponding section.
- `registry`: update the domain to the one you will use for the correctomatic's internal registry.
- `docker`: update the domain to a valid value in your domain, it will point to localhost in production, but you will probably use it for debugging.
- `lets_encrypt_email`: TO-DO

These values are used only for development, you can leave them if you are running the playbook in production:
- `correctomatic_api_domain`: used only in development mode, the API **must** be protected in production.

### Secrets

TO-DO

## Running the playbook
[Install ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html), you will need it to run the playbook. Usually done with `pipx install --include-deps ansible`.

Run the playbook:
```sh
ansible-playbook playbook.yml
```

## Working with the private registry

The correctomatic works with a private registry (usually, the correction images are kept private) There is another file with [documentation on the private registry](README_registry.md)

## Development

If you want to run the playbook in development mode (for testing changes, for example) follow the instructions in this section.

### Prepare your host

You will need to create some entries in `/etc/hosts` to reply the DNS entries that the correctomatic would have in a real deployment:

```
192.168.56.56  correctomatic_vps
192.168.56.56  <your registry domain, ie, registry.my.correctomatic.com>
# For connecting to the VPS docker's server:
192.168.56.56  <your docker domain, ie, docker.my.correctomatic.com>

```
### Prepare the virtual host

1) Install an Ubuntu 22.04 server. The playbook expects a user `ansible` with password `ansible` (you can change the password modifying `secrets/sudo_password.yml`)

2) Configure the network. You will need two networks in the virtual machine:
   - One NAT network, so the VPS can connect to the internet
   - One host only network so you can access the VPS from your host

   Folow this steps:
   1) Create a NAT network using the VirtualBox network manager. Assign the `10.10.10.0/24` address to the network, the virtual machine will have the address `10.10.10.10`.
   2) Create a host only network using the VirtualBox network manager. The address will be `192.168.56.1/24`. You don't need to have DHCP enabled.
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

Alternatively, you can use a bridged network. In that case, you will need to assign a fixed IP to the virtual machine, either by configuring the DHCP of your network or by modifying the netplan.

3) Generate a ssh key. This will generate a `id_ansible` key pair in `~/.ssh`:
```sh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_ansible -C "ansible@correctomatic_vps"
```

4) Copy the key to the VPS:
```sh
ssh-copy-id -i  ~/.ssh/id_ansible ansible@correctomatic_vps
```

At this point, create a snapshot and name it `clean_state`. You can restore this snapshot later to retry the ansible playbook with a clean machine. There is a script, `restore_snapshot.sh`, for restoring that snapshot automatically.

### Connecting to the VPS docker daemon from the local machine

If you want to connect to the Docker server in the VPS from your local machine, you need to download the certificates from the VPS and configure the Docker client to use them. Note that **this will only work if the playbook has run in development mode**. If not, the docker server is not accessible from the outside.

1) Download the certificates. **YOU MUST DO THIS EACH TIME THE CERTIFICATES ARE REGENERATED**.
2) Test the connection.
3) Optional: create a Docker context for future connections. **YOU MUST DO THIS EACH TIME THE CERTIFICATES ARE REGENERATED**.

#### Download the certificates

The certificates are stored in the VPS in the following paths:
- CA certificate: `/etc/docker/ca/ca-certificate.pem`
- Client certificate: `/etc/docker/certs/correctomatic-client-certificate.pem`
- Client private key: `/etc/docker/certs/correctomatic-private-key.pem`

They should be copied to the local machine in a directory. For example, you can use `~/.correctomatic/certs/`, and the names are, by convention, `ca.pem`, `cert.pem`, and `key.pem`. There is an script that does this for you:`utils\docker_download_certs.sh`), you will need to have `sshpass` installed before running it.


#### Test connection from local machine:

The connection can be tested using environment variables. The following commands should be executed in the local machine:

```sh
VPS_HOST=docker.correctomatic.alvaromaceda.es


export DOCKER_HOST=tcp://$VPS_HOST:2376
export DOCKER_CERT_PATH=~/.correctomatic/certs
export DOCKER_TLS_VERIFY=1

docker info
```

Remember to unset the variables when you are done:

```sh
unset DOCKER_HOST
unset DOCKER_CERT_PATH
unset DOCKER_TLS_VERIFY
```

#### Create a Docker context

You can create a docker context to avoid setting the environment variables each time you want to connect to the VPS. There is
a script that does this for you: `utils\docker_create_context.sh`. Update the script first to use the correct domain name. **You will need to recreate the context each time the certificates are regenerated**.

Once the context is created, you can activate it and run docker commands as usual, but they will be executed in the VPS:

```sh
docker context use correctomatic_vps

docker info
docker image pull alpine:latext
...
```

To switch back to the local context run `docker context use default`.

#### Test the connection using Dockerode

The Correctomatic uses Dockerode to interact with the Docker daemon. Here you have
an example to test the connection using Dockerode (you will need to add the `dockerode`
dependency to your project):


```js
import fs from 'fs';
import path from 'path';
import os from 'os'; // Importing os module for accessing home directory

import Docker from 'dockerode';

// Get the user's home directory
const homeDir = os.homedir();
const certDir = path.join(homeDir, '.correctomatic', 'certs');

// Define paths to your certificate files relative to the home directory
const caPath = path.join(certDir, 'ca.pem');
const certPath = path.join(certDir, 'cert.pem');
const keyPath = path.join(certDir, 'key.pem');

// Read certificate files synchronously
const ca = fs.readFileSync(caPath);
const cert = fs.readFileSync(certPath);
const key = fs.readFileSync(keyPath);

const docker = new Docker({
  host: 'docker.correctomatic.alvaromaceda.es',
  port: 2376,
  ca,
  cert,
  key
});

// Example: List containers
docker.listContainers({ all: true }, function (err, containers) {
  if (err) {
    return console.error('Error:', err);
  }
  console.log('Containers:', containers);
});
```

### Test the redis server

The VPS's Redis server can be accessed using `redis-cli`, use the same password defined in `secrets/redis_password.yml`. Take in account that the redis server won't be accesible in production mode, the firewall ports are closed and redis is listening only at localhost:

```sh
redis-cli -h 192.168.56.56 -p 6379 -a 'your_password'

192.168.56.56:6379> ping
PONG
```

There is a docker compose file, `/utils/docker_compose_dashboards.yml`, that can be used to run RedisInsight and BullMQ dashboards.

If you prefer to launch them by hand, to use RedisInsight web frontend to debug the server:

```sh
# This is for keeping configuration, run
# docker volume rm redisinsight when done
docker volume create vps-redisinsight

docker run \
  --rm \
  --network host \
  --name VPS-redisinsight \
  -v vps-redisinsight:/data \
  redis/redisinsight
```
The server can be accessed at [http://localhost:5540](http://localhost:5540).

The container will have an address in host's network. For configuring RedisInsight, Redis server will be accesible at the VPS host only IP (192.168.56.56) port 6379.

If you want to debug BullMQ, run a web dashboard with:

```sh
docker run \
  --rm \
  --network host \
  --name VPS-bullmq \
  igrek8/bullmq-dashboard \
  --redis-host 192.168.56.56 \
  --bullmq-prefix bull \
  --host 192.168.56.1 \
  --redis-password <redis password here>"
```
The server can be accessed at [http://localhost:3000](http://localhost:3000).
