# fedora-dev-container

This is a git repository managing a standard base image for work. Fedora is the base.

## Usage examples
- Example usage in vs code using devcontainers:
```json
{
  "name": "Jacob Dev Environment",
  "image": "quay.io/jacobdschreuder/fedora-dev-container:latest",
  
  "runArgs": [
    "--privileged",
    "--security-opt", "label=disable"
  ],
  
  "mounts": [
    "source=${localEnv:USERPROFILE}/.ssh,target=/tmp/.ssh-host,type=bind,readonly"
  ],
  
  "customizations": {
    "vscode": {
      "extensions": []
    }
  },
  
  "postCreateCommand": "mkdir -p ~/.ssh && cp -r /tmp/.ssh-host/* ~/.ssh/ && chmod 700 ~/.ssh && chmod 400 ~/.ssh/id_* && chmod 644 ~/.ssh/*.pub && echo 'Ready!'"
}
```

- Example usage in che workspace devfile
```yaml
schemaVersion: 2.3.0
metadata:
  name: development

components:
  - container:
      args: ['tail', '-f', '/dev/null']
      image: 'quay.io/jacobdschreuder/fedora-dev-container:latest'
      memoryRequest: 256M
      memoryLimit: 6Gi
      cpuRequest: 250m
      cpuLimit: 2000m
    name: ansible

```