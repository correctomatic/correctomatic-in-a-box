## Configure docker to allow remote connetions

### Connecting to the VPS docker daemon from the local machine

If you want to connect to the Docker server in the VPS from your local machine, you need to download the certificates from the VPS and configure the Docker client to use them. Note that **this will only work if the playbook has been run in development mode**. If not, the docker server is not accessible from the outside.

1) Download the certificates. **YOU MUST DO THIS EACH TIME THE CERTIFICATES ARE REGENERATED**
2) Test the connection.
3) Optional: create a Docker context for future connections. **YOU MUST DO THIS EACH TIME THE CERTIFICATES ARE REGENERATED**

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

You can create a docker context to avoid setting the environment variables each time you want to connect to the VPS. There is
a script that does this for you: `utils\docker_create_context.sh`. **You will need to recreate the context each time the certificates are regenerated**.

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

