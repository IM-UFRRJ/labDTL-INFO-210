#!/bin/bash

source common_vars.sh

PLAYBOOKS="playbooks-enabled/halt.yml"
echo "ansible-playbook -i ${FILE_HOSTS} -u ${HOST_USER} -s -K ${PLAYBOOKS} -e ${EXTRA_ARGS}"
ansible-playbook -i ${FILE_HOSTS} -u ${HOST_USER} -K ${PLAYBOOKS} -e ${EXTRA_ARGS}

