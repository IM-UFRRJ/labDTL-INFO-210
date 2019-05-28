#!/bin/bash

source common_vars.sh

echo "ansible -i ${VALID_FILE_HOSTS} ${HOSTS} -u ${HOST_USER} --private-key=${PATH_SSH_KEYS} -e \"${EXTRA_VARS}\" -m setup"
ansible -i ${VALID_FILE_HOSTS} ${HOSTS} -u ${HOST_USER} --private-key=${PATH_SSH_KEYS} -e "${EXTRA_VARS}" -m setup

RESULT=$( ansible -i ${VALID_FILE_HOSTS} ${HOSTS} -u ${HOST_USER} --private-key=${PATH_SSH_KEYS} -e "${EXTRA_VARS}" -m setup )
LIST_VALID_HOSTS=$( echo $RESULT | grep -oP "[0-9]+.[0-9]+.[0-9]+.[0-9]+(?= \| SUCCESS)" )
LIST_HOSTNAMES=$( echo $RESULT | grep -oP "(?:\"ansible_hostname\"\: \"*\K)[^\"]*" )
if [ -z "${LIST_VALID_HOSTS}" ]; then
	LIST_VALID_HOSTS=$( echo $RESULT | grep -oP "[\S]+(?= \| SUCCESS)" )
fi
echo "Valid hosts:"
echo "${LIST_VALID_HOSTS}"
echo "Hostnames:"
echo "${LIST_HOSTNAMES}"

if [ -z "${LIST_VALID_HOSTS}" ]
then
	ansible -vvvv -i ${VALID_FILE_HOSTS} ${HOSTS} -u ${HOST_USER} --private-key=${PATH_SSH_KEYS} -e "${EXTRA_VARS}" -m setup
else
	cat ${VALID_FILE_HOSTS} > ${FILE_HOSTS}
	while read VALID_HOST <&3 && read HOSTNAME <&4; do
		if [[ ${HOSTNAME} != "${HOSTS}"* ]]; then
			HOSTNAME="${HOSTS}-${HOSTNAME}"
		fi
		sed -i "s/${VALID_HOST}/${HOSTNAME}/g" ${FILE_HOSTS}
	done 3<<<"${LIST_VALID_HOSTS}" 4<<<"${LIST_HOSTNAMES}"

	echo ""
	echo "======================================================="
	echo "cat ${FILE_HOSTS}"
	echo "======================================================="
	cat ${FILE_HOSTS}
	echo "======================================================="
	echo ""

fi
