#!/usr/bin/env bash

export PS4='[TRACE $LINENO] '

set -xe

# bring up machines
vagrant up

# execute extra steps
test -f deploy-extra.sh && ./deploy-extra.sh

# wait for them to be visible
while ! ansible all -m ping; do
    sleep 10
    date
done

# deploy
ansible-playbook site.yml
