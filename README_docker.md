## Configure docker to allow remote connetions

### Prepare server remote access

```sh
DOCKKER_SERVER=docker.correctomatic.alvaromaceda.es

# Create directories for storing certificates
sudo mkdir -p /etc/docker/certs
sudo mkdir -p /etc/docker/ca

# Generate CA private and public keys
openssl genrsa -aes256 -out /etc/docker/ca/ca-key.pem 4096
openssl req -new -x509 -days 365 -key /etc/docker/ca/ca-key.pem -sha256 -out /etc/docker/ca/ca.pem

# Generate server private key
openssl genrsa -out /etc/docker/certs/server-key.pem 4096

# Generate server certificate signing request (CSR)
openssl req -subj "/CN=$DOCKKER_SERVER" -new -key /etc/docker/certs/server-key.pem -out /etc/docker/certs/server.csr

# Sign server certificate with the CA
echo "subjectAltName = DNS:$DOCKKER_SERVER" > /etc/docker/certs/extfile.cnf
openssl x509 -req -days 365 -in /etc/docker/certs/server.csr -CA /etc/docker/ca/ca.pem -CAkey /etc/docker/ca/ca-key.pem -CAcreateserial -out /etc/docker/certs/server-cert.pem -extfile /etc/docker/certs/extfile.cnf

# Generate client private key
openssl genrsa -out /etc/docker/certs/key.pem 4096

# Generate client certificate signing request (CSR)
openssl req -subj '/CN=client' -new -key /etc/docker/certs/key.pem -out /etc/docker/certs/client.csr

# Sign client certificate with the CA
echo extendedKeyUsage = clientAuth > /etc/docker/certs/extfile-client.cnf
openssl x509 -req -days 365 -in /etc/docker/certs/client.csr -CA /etc/docker/ca/ca.pem -CAkey /etc/docker/ca/ca-key.pem -CAcreateserial -out /etc/docker/certs/cert.pem -extfile /etc/docker/certs/extfile-client.cnf

# Set permissions
sudo chmod -R 700 /etc/docker/certs
sudo chmod -R 700 /etc/docker/ca
```

sudo nano /etc/docker/daemon.json
```json
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"],
  "tls": true,
  "tlscacert": "/etc/docker/ca/ca.pem",
  "tlscert": "/etc/docker/certs/server-cert.pem",
  "tlskey": "/etc/docker/certs/server-key.pem",
  "tlsverify": true
}
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
