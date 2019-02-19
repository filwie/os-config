#!/usr/bin/env zsh

if docker ps -a | grep arch-sshd 2> /dev/null; then
    docker rm -f arch-sshd
fi

docker run -dit -p 22222:22 --name arch-sshd devarch
echo -n "ssh root@localhost -p 22222"
echo " -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null"

