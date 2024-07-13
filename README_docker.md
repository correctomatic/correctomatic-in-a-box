## Configure docker to allow remote connetions

### Connecting to the VPS docker daemon from the local machine

https://collabnix.com/how-to-connect-to-remote-docker-using-docker-context-cli/


https://gist.github.com/kekru/4e6d49b4290a4eebc7b597c07eaf61f2


1) Download the certificates. **YOU MUST DO THIS EACH TIME THE CERTIFICATES ARE REGENERATED**
2) Configure the local machine to connect to the remote server



This is an example of how to download the certificates from the remote machine, but you can copy the certificates using any method you prefer:

```bash
VPS_USER=ansible
VPS_HOST=correctomatic_vps
CERTIFICATES_DIR=~/.config/correctomatic/certs/

mkdir -p "$CERTIFICATES_DIR"
echo -n "Sudo password:" && read -s vps_password

# Server Certificate authority
ssh -tt $VPS_USER@$VPS_HOST "echo $vps_password | sudo -S cat /etc/docker/ca/ca-certificate.pem" > "$CERTIFICATES_DIR/ca-certificate.pem"

# Client keys
ssh -tt $VPS_USER@$VPS_HOST "echo $vps_password | sudo -S cat /etc/docker/certs/correctomatic-client-certificate.pem" > "$CERTIFICATES_DIR/correctomatic-client-certificate.pem"
ssh -tt $VPS_USER@$VPS_HOST "echo $vps_password | sudo -S cat /etc/docker/certs/correctomatic-private-key.pem" > "$CERTIFICATES_DIR/correctomatic-private-key.pem"
```
**Check the certificates**: if you had an error typing the password, the files will have error messages.



TO-DO

```sh
VPS_HOST=correctomatic_vps



export DOCKER_HOST=tcp://$VPS_HOST:2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=<path-to-certificates>
```






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
