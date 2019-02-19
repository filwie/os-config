#!/usr/bin/env zsh

HOST_PUB_KEY="$(cat ${HOME}/.ssh/id*.pub)"
echo $HOST_PUB_KEY > host_pubkey

docker build . -t devarch

rm host_pubkey
