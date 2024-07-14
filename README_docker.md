## Configure docker to allow remote connetions

### Connecting to the VPS docker daemon from the local machine

If you want to connect to the Docker server in the VPS from your local machine, you need to download the certificates from the VPS and configure the Docker client to use them. Note that **this will only work if the playbook has been run in development mode**. If not, the docker server is not accessible from the outside.

1) Download the certificates. **YOU MUST DO THIS EACH TIME THE CERTIFICATES ARE REGENERATED**
2) Test the connection
3) Optional: create a Docker context for future connections

#### Download the certificates

The certificates are stored in the VPS in the following paths:
- CA certificate: `/etc/docker/ca/ca-certificate.pem`
- Client certificate: `/etc/docker/certs/correctomatic-client-certificate.pem`
- Client private key: `/etc/docker/certs/correctomatic-private-key.pem`

They should be copied to the local machine in a directory. For example, you can use `~/.correctomatic/certs/`, and the names are, by convention, `ca.pem`, `cert.pem`, and `key.pem`. There is an script that does this for you:`utils\docker_download_certs.sh`).


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

You can create a docker context to avoid setting the environment variables each time you want to connect to the VPS. You have a script that does this for you: `utils\docker_create_context.sh`.

Once the context is created, you can activate it and run docker commands as usual, but they will be executed in the VPS:

```sh
docker context use correctomatic_vps

docker info
docker image pull alpine:latext
...
```

To switch back to the local context run `docker context use default`.


--------------------------------------------------------
DOCKERODE
--------------------------------------------------------

### Prepare client

#### Copy Certificates
Copy the client certificates and CA certificate from the remote machine to the local machine. For example, you can use scp:

```sh
scp user@docker.example.com:/etc/docker/ca/ca.pem /path/to/local/ca.pem
scp user@docker.example.com:/etc/docker/certs/cert.pem /path/to/local/cert.pem
scp user@docker.example.com:/etc/docker/certs/key.pem /path/to/local/key.pem
```

#### Configure Dockerode
Set up dockerode to use the TLS certificates and the domain name. Create a JavaScript file (e.g., docker.js) and use the following code:

```js
const Docker = require('dockerode');
const fs = require('fs');

const docker = new Docker({
  host: 'docker.example.com',
  port: 2376,
  ca: fs.readFileSync('/path/to/local/ca.pem'),
  cert: fs.readFileSync('/path/to/local/cert.pem'),
  key: fs.readFileSync('/path/to/local/key.pem')
});

// Example: List containers
docker.listContainers({ all: true }, function (err, containers) {
  if (err) {
    return console.error('Error:', err);
  }
  console.log('Containers:', containers);
});
```
