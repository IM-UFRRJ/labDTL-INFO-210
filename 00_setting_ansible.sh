#!/bin/bash

source common_vars.sh

echo "ansible -i ${ALL_FILE_HOSTS} ${HOSTS} -u ${HOST_USER} --private-key=${PATH_SSH_KEYS} -e \"${EXTRA_VARS}\" -m setup"
ansible -i ${ALL_FILE_HOSTS} ${HOSTS} -u ${HOST_USER} --private-key=${PATH_SSH_KEYS} -e "${EXTRA_VARS}" -m setup

RESULT=$( ansible -i ${ALL_FILE_HOSTS} ${HOSTS} -u ${HOST_USER} --private-key=${PATH_SSH_KEYS} -e "${EXTRA_VARS}" -m setup )
LIST_VALID_IPS=$( echo $RESULT | grep -oP "[0-9]+.[0-9]+.[0-9]+.[0-9]+(?= \| SUCCESS)" )
LIST_HOSTNAMES=$( echo $RESULT | grep -oP "(?:\"ansible_hostname\"\: \"*\K)[^\"]*" )
echo "Valid IPs:"
echo "${LIST_VALID_IPS}"
echo "Hostnames:"
echo "${LIST_HOSTNAMES}"

if [ -z "${LIST_VALID_IPS}" ]
then
	ansible -vvvv -i ${ALL_FILE_HOSTS} ${HOSTS} -u ${HOST_USER} --private-key=${PATH_SSH_KEYS} -e "${EXTRA_VARS}" -m setup
else
	echo "[${HOSTS}]" > ${FILE_HOSTS}
	while read HOST_IP <&3 && read HOSTNAME <&4; do
		echo -e "${HOSTNAME}-${HOST_IP}\tansible_host=${HOST_IP}" >> ${FILE_HOSTS}
	done 3<<<"${LIST_VALID_IPS}" 4<<<"${LIST_HOSTNAMES}"
fi

cat ${FILE_HOSTS}
