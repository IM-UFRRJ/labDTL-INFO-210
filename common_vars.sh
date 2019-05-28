#!/bin/bash

passphrase() {
	echo "$( LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 13 ; echo )"
}

munge_word() {
   local word=$1
   echo "$(echo $word | sed 's/e/3/g;s/i/1/g;s/l/1/g;s/o/0/g;s/s/5/g')"
}

enter_pwd() {
	local PASSWORD_WRONG=1
	local FOR_PWD=" for $1"
	local MUNGED=$2
	local PASSWORD=''
	local PASSWORD_CHECK=''
	while [ ${PASSWORD_WRONG} -gt 0 ]; do
		read -s -p "Enter password${FOR_PWD}: " PASSWORD
		echo "" >&2
		if [ -n "$MUNGED" ] && [ "${PASSWORD}" != $( munge_word "${PASSWORD}" ) ] ; then
			echo "Password not munged! Try again." >&2
			continue
		fi
		read -s -p "Retry password${FOR_PWD}: " PASSWORD_CHECK
		echo "" >&2
		if [ "${PASSWORD}" != "${PASSWORD_CHECK}" ]; then
			echo "Unchecked password! Try again." >&2
			PASSWORD_WRONG=$(( $PASSWORD_WRONG + 1 ));
		else
			echo "Checked password!" >&2
			PASSWORD_WRONG=0
		fi
	done
	echo "${PASSWORD}"
}

ROOT_PATH_KEYS=$(pwd)/"keys"
mkdir -p ${ROOT_PATH_KEYS}

while [ -z ${HOST_USER} ]; do
	read -p "Enter remote sudo user: " HOST_USER
done

FILE_EXTRA_VARS="${ROOT_PATH_KEYS}/extra_vars_${HOST_USER}.yml"
EXTRA_VARS='ansible_python_interpreter=/usr/bin/python3'
PATH_SSH_KEYS="${ROOT_PATH_KEYS}/id_rsa_$(hostname)"

source net_vars.sh
