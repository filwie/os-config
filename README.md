# os-config
## Description
This playbook configures `Mac OS` or `Arch` node to suit my preferences. For `Mac OS` it mostly installs stuff,
while for `Arch` it is more of a complete setup. I wrote it for myself, so it will probably be of no
use for you, random Internet person.

Currently it is kind of a mess, but should work.

There is also `scripts` directory that holds some tools like `configure_arch.sh` script,
which can be used to perform most basic configuration like adding groups, users,
installing basic packages.

`Tasks` generally have corresponding `vars` file. If a variable is not present there, it might be found in `defaults` and its role is to be overwritten on `playbook` level.

## Prerequisites
1. **control machine**:
    - Ansible
    - `Zsh` (to run the `run.sh` script)
2. **managed node**:
    - Python
    - Internet access
    - `Arch` or `Mac OS` (`Ubuntu` support is planned)
    - [optional] `Zsh` to run `configure_arch.sh` script

## Guide
#### Arch
After installing clean Arch, following steps can be taken to

- **managed node**: Start and enable `dhcpcd`
``` sh
systemctl start dhcpcd
systemctl enable dhcpcd
```

- **managed node**: Install `zsh`
``` sh
pacman -Sy zsh
```

- **control machine**: Install `ansible`. Depending on OS
``` sh
pacman -Sy ansible
pip install --user ansible
brew install ansible
```

- **control machine**: If `control machine` is not the same host as `managed node`,
`serve.sh` script might be used to transfer scripts to the managed `node`.

- **managed node**: Download and run script
``` sh
curl -o configure_arch.sh http://{{ CONTROL MACHINE IP }}:8000/configure_arch.sh
chmod u+x configure_arch.sh
./configure_arch.sh --help
```

- **control machine**: Create `inventory`. For example
``` ini
[somehost]
someip
[somehost:vars]
ansible_ssh_user = someuser
```
Or for localhost
``` ini
[local]
localhost
[local:vars]
ansible_connection = local
```

- **control machine**: Run `ansible-playbook` using provided `run.sh` script
