# Ansible Docker Runner

A minimal Docker image based on `alpine/ansible` which allows running Ansible commands and playbooks in a containerized environment. That way you don't need to perform complicated local install of Ansible and its dependencies on your local machine.  
It supports installing Ansible Galaxy collections/roles and Python packages from requirements files.

## Features

- Runs Ansible commands and playbooks out of the box.
- Installs Ansible Galaxy collections/roles from `requirements.yml`.
- Installs Python packages from `requirements.txt`.

## Usage

Run image with passing your current directory as volume to `/playbooks`. After that you can write ansible commands and pass files (configs, inventory, playbooks) as normal.  

Image will automatically install dependencies if requirements files (`requirements.yml`, `requirements.txt`) are present in the current directory. Below are some examples of how to use the image.

Run and show ansible help (default CMD):
```bash
docker run --rm local/ansible-runner:latest
```

Run module:
```bash
docker run --rm -v ~/.ssh:/home/ansible/.ssh:ro local/ansible-runner:latest ansible all -m ping
```

Run playbook and pass inventory located in current directory:
```bash
docker run --rm -v $(pwd):/playbooks -v ~/.ssh:/home/ansible/.ssh:ro local/ansible-runner:latest ansible-playbook playbook-example.yml -i inventory
```

### Shell functions

Use these shell functions to run Ansible commands conviniently without long docker commands.

```bash
_ansible_base() {
  local cmd="$1"; shift
  docker run --rm -it \
    --network host \
    -u $(id -u):$(id -g) \
    -v ~/.ssh:/home/ansible/.ssh:ro \
    -v "$(pwd)":/playbooks \
    -v /etc/ansible:/etc/ansible:ro \
    -v /var/log/ansible:/var/log/ansible \
    local/ansible-runner:latest "$cmd" "$@"
}

ansible() {
  _ansible_base ansible "$@"
}

ansible-playbook() {
  _ansible_base ansible-playbook "$@"
}
```

After adding these functions to your shell profile (e.g. `~/.bashrc` or `~/.zshrc`), you can run `ansible` and `ansible-playbook` commands directly. This imitates ansible being installed on machine. For example:

```bash
ansible all -m ping -i inventory
ansible-playbook site.yml -i inventory
```
### Caching installed dependencies
If your reqirements files are large and running installation each time is slow, you can add these volumes to cache installed dependencies:
```bash
-v ansible-cache:/home/ansible/.ansible \
-v ansible-pip-cache:/home/ansible/.cache/pip \
```

To clear cache, remove these volumes:
```bash
docker volume rm ansible-cache ansible-pip-cache
```

## Building locally

Clone the repository:
```bash
git clone https://github.com/your-repo/ansible-docker.git
cd ansible-docker
```

Build the image:
```bash
docker buildx build -t local/ansible-runner:latest .
```

## Knowm Issues

If you get `ssh: Bad owner or permissions` errors, try to build image passing UID and GID of your local machine user:
```bash
docker buildx build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) -t local/ansible-runner:latest .
```

Do not forget to run your local image `local/ansible-runner:latest`, instead of pulling from remote registry. Change it in the shell aliases above if needed.