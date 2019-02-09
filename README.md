# os-config

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

- **control machine**: Run `ansible-playbook` using provided `run.sh` script
