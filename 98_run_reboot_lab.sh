#!/bin/bash

source common_vars.sh

PLAYBOOKS="playbooks-enabled/reboot.yml"
echo "ansible-playbook -i ${FILE_HOSTS} -u ${HOST_USER} -s -K ${PLAYBOOKS} -e ${EXTRA_VARS}"
ansible-playbook -i ${FILE_HOSTS} -u ${HOST_USER} -K ${PLAYBOOKS} -e ${EXTRA_VARS}

