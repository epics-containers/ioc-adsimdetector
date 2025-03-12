#!/bin/bash

# do ansible setup for the IOC.

# ansible playbook and roles come from the ibek-support repo always
ansible_dir=/epics/generic-source/ibek-support/_ansible

ansible-playbook \
    ${ansible_dir}/ioc_playbook.yml \
    -i ${ansible_dir}/hosts.yml

