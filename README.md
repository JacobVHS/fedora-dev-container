# fedora-dev-container

This is a git repository managing a standard base image for work. Fedora is the base.

## Usage examples

- Use as an ad hoc shell on a windows host with docker or podman installed
```powershell
function bash {
    $containerName = "linux-fedora-bash"
    $imageName = "quay.io/jacobdschreuder/fedora-dev-container:latest"
    $sshSource = "$env:USERPROFILE\.ssh"
    
    # Detect container runtime (podman or docker)
    $runtime = $null
    if (Get-Command podman -ErrorAction SilentlyContinue) {
        $runtime = "podman"
    }
    elseif (Get-Command docker -ErrorAction SilentlyContinue) {
        $runtime = "docker"
    }
    else {
        Write-Host "Error: Neither podman nor docker found in PATH" -ForegroundColor Red
        return
    }
    
    Write-Verbose "Using container runtime: $runtime"
    
    # Check if container exists and is running
    $containerStatus = & $runtime ps -a --filter "name=^${containerName}$" --format "{{.Status}}" 2>$null
    
    if ($containerStatus -match "^Up") {
        # Container is running, attach to it
        Write-Host "Attaching to existing container: $containerName" -ForegroundColor Green
        & $runtime exec -it $containerName zsh
    }
    elseif ($containerStatus) {
        # Container exists but is stopped, start and attach
        Write-Host "Starting stopped container: $containerName" -ForegroundColor Yellow
        & $runtime start $containerName | Out-Null
        & $runtime exec -it $containerName zsh
    }
    else {
        # Container doesn't exist, create and run it
        Write-Host "Creating new container: $containerName" -ForegroundColor Cyan
        
        # Check if .ssh directory exists
        if (Test-Path $sshSource) {
            & $runtime run -dit `
                --name $containerName `
                -v "${sshSource}:/home/user/.ssh:Z" `
                $imageName zsh
            
            # Set correct permissions on .ssh directory inside container
            Write-Host "Setting SSH permissions..." -ForegroundColor Cyan
            & $runtime exec $containerName sh -c "chmod 700 /home/user/.ssh && chmod 600 /home/user/.ssh/* 2>/dev/null || true"
        }
        else {
            Write-Host "Warning: $sshSource not found, starting without SSH keys" -ForegroundColor Yellow
            & $runtime run -dit `
                --name $containerName `
                $imageName zsh
        }
        
        # Attach to the newly created container
        & $runtime exec -it $containerName zsh
    }
}

# Optional: Add an alias for 'linux' as well
Set-Alias -Name linux -Value bash
```

- The same as the above, but for MacOS systems
```shell
#!/bin/bash

bash() {
    local container_name="linux-fedora-bash"
    local image_name="quay.io/jacobdschreuder/fedora-dev-container:latest"
    local ssh_source="$HOME/.ssh"
    
    # Detect container runtime (podman or docker)
    local runtime=""
    if command -v podman &> /dev/null; then
        runtime="podman"
    elif command -v docker &> /dev/null; then
        runtime="docker"
    else
        echo "Error: Neither podman nor docker found in PATH" >&2
        return 1
    fi
    
    # Check if container exists and is running
    local container_status
    container_status=$($runtime ps -a --filter "name=^${container_name}$" --format "{{.Status}}" 2>/dev/null)
    
    if [[ "$container_status" =~ ^Up ]]; then
        # Container is running, attach to it
        echo -e "\033[0;32mAttaching to existing container: $container_name\033[0m"
        $runtime exec -it "$container_name" zsh
    elif [[ -n "$container_status" ]]; then
        # Container exists but is stopped, start and attach
        echo -e "\033[0;33mStarting stopped container: $container_name\033[0m"
        $runtime start "$container_name" > /dev/null
        $runtime exec -it "$container_name" zsh
    else
        # Container doesn't exist, create and run it
        echo -e "\033[0;36mCreating new container: $container_name\033[0m"
        
        # Check if .ssh directory exists
        if [[ -d "$ssh_source" ]]; then
            # Note: Using :z (lowercase) for compatibility, or removing SELinux label if not needed
            if [[ "$runtime" == "podman" ]]; then
                # Podman on macOS might support :Z flag
                $runtime run -dit \
                    --name "$container_name" \
                    -v "${ssh_source}:/home/user/.ssh:Z" \
                    "$image_name" zsh
            else
                # Docker doesn't use SELinux labels
                $runtime run -dit \
                    --name "$container_name" \
                    -v "${ssh_source}:/home/user/.ssh" \
                    "$image_name" zsh
            fi
            
            # Set correct permissions on .ssh directory inside container
            echo -e "\033[0;36mSetting SSH permissions...\033[0m"
            $runtime exec "$container_name" sh -c "chmod 700 /home/user/.ssh && chmod 600 /home/user/.ssh/* 2>/dev/null || true"
        else
            echo -e "\033[0;33mWarning: $ssh_source not found, starting without SSH keys\033[0m"
            $runtime run -dit \
                --name "$container_name" \
                "$image_name" zsh
        fi
        
        # Attach to the newly created container
        $runtime exec -it "$container_name" zsh
    fi
}

# Optional: Add an alias for 'linux' as well
alias linux='bash'
```

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
    name: fedora-dev-container
```