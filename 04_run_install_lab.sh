#!/bin/bash

source common_vars.sh

if [ ! -f ${FILE_EXTRA_VARS} ] ; then

	PASSWD=$( enter_pwd "sudo system user ${HOST_USER}" )
	EXTRA_VARS="${EXTRA_VARS} ansible_sudo_pass=${PASSWD}"

	EXTRA_VARS="${EXTRA_VARS} ssh_client_ipv4=${NET_IP}"

	LIST_USERS=(
		 "prof-dtl"
		 "prof-dcc"
		 "prof-ext"
		 "aluno-dtl"
		 "aluno-dcc"
		 "extensao"
	)

	echo ""
	for USR in "${LIST_USERS[@]}"; do
		ARG_ENTER_PWD="system user ${USR//-/}"
		echo "Setting ${ARG_ENTER_PWD}"
		if [[ $USR == *"prof"* ]]; then
			USR_PWD=$( enter_pwd "${ARG_ENTER_PWD}" 1 )
		else
			USR_PWD=$( enter_pwd "${ARG_ENTER_PWD}" )
		fi
		USR_PHR=$( passphrase )
		USR_KEY=${USR//-/_}
		EXTRA_VARS="${EXTRA_VARS} pwd_${USR_KEY}=${USR_PWD}"
		EXTRA_VARS="${EXTRA_VARS} phr_${USR_KEY}=${USR_PHR}"
		echo ""
	done

	PATH_MYSQL_CNF="${ROOT_PATH_KEYS}/.my.cnf"
	DB_ROOT_PASSWORD=$( enter_pwd "database user root" 1 )
	echo "[client]" > ${PATH_MYSQL_CNF}
	echo "user=root" >> ${PATH_MYSQL_CNF}
	echo "password=${DB_ROOT_PASSWORD}" >> ${PATH_MYSQL_CNF}
	EXTRA_VARS="${EXTRA_VARS} path_mysql_cnf=${PATH_MYSQL_CNF}"
	EXTRA_VARS="${EXTRA_VARS} path_pwd=$(pwd)"

	EXTRA_VARS="${EXTRA_VARS// /\\n}"
	EXTRA_VARS="${EXTRA_VARS//=/: }"
	echo -e "${EXTRA_VARS}" > ${FILE_EXTRA_VARS}
fi

PATH_PLAYBOOKS="playbooks-enabled"
rm -f ${PATH_PLAYBOOKS}/*.retry
LIST_YML=(
	"init.yml"
	#"reboot.yml"
	"apt_set_proxy.yml"
	#"test.yml"
	"change_hostname.yml"
	"install_hwe.yml"
	#"00*.yml"
	#"01*.yml"
	"[0]*.yml"
	"reboot.yml"
	"[1]*.yml"
	#"2*.yml"
	"[2-7]*.yml"
	#"30*.yml"
	#"84*.yml"
	#"85*.yml"
	#"86*.yml"
	#"87*.yml"
	"[8]*.yml"
	"[9]*.yml"
	#"list-apt.yml"
	#"list-locales.yml"
	"final.yml"
	"apt_unset_proxy.yml"
	"reboot.yml"
	#"check_hostname.yml"
	#"halt.yml"
)

PLAYBOOKS=""
for YML in "${LIST_YML[@]}"; do
	PLAYBOOKS="${PLAYBOOKS} ${PATH_PLAYBOOKS}/${YML}"
done
echo ""
echo "ansible-playbook -f ${FORKS} -i ${FILE_HOSTS} -u ${HOST_USER} ${PLAYBOOKS} --private-key=${PATH_SSH_KEYS} -e \"@${FILE_EXTRA_VARS}\""
ansible-playbook -f ${FORKS} -i ${FILE_HOSTS} -u ${HOST_USER} ${PLAYBOOKS} --private-key=${PATH_SSH_KEYS} -e "@${FILE_EXTRA_VARS}"
