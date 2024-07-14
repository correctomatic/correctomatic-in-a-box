
TO-DO: write a script for this

How to delete an image tag/image from docker registry v2.4

1) Get tags list for repo

```sh
curl -s GET http://<registry_host:port>/v2/<repo_name>/tags/list
```

2) Get manifest for selected tag

```sh
curl -sI GET http://<registry_host:port>/v2/<repo_name>/manifests/<tag_name>
```

3) Copy repo digest hash from response header

```
Docker-Content-Digest: <digest_hash>
```

4) Delete manifest (soft delete). This request only marks image tag as deleted and doesn't delete files from file system. If you want to delete data from file system, run this step and go to the next step

```sh
curl -svIX DELETE http://<registry_host:port>/v2/<repo_name>/manifests/<digest_hash>
```
  Note! You must set headers for request - Accept: application/vnd.docker.distribution.manifest.v2+json

5) Delete image data from file system

  Run command from the registry host machine:
```sh
docker exec -it <registry_container_id or name> bin/registry garbage-collect <path/to/registry/config.yml>
```

  Note! Usually, `<path_to_registry_config>==>/etc/docker/registry/config.yml`
