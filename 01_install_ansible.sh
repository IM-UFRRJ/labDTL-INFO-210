#!/bin/bash

# ATENÇÃO
# em cada PC remoto, logo após a instalação limpa do ubuntu LTS desktop/server,
# e cada máquina deve receber um nome único de até 6 chars (ex: número do patrimônio)

#sudo apt install openssh-client openssh-server -y


# instalação de programas prévios no PC do administrador
if ! grep -q "^deb .*ansible" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
	sudo add-apt-repository -y 'ppa:ansible/ansible'
	sudo apt update
fi
sudo apt install ansible expect nmap squid -y

SQUID_CONF="/etc/squid/squid.conf"
SQUID_DENY_ALL='http_access deny all'
SQUID_OBJ_SIZE='# maximum_object_size 4 MB'
SQUID_EXP_TIME='# minimum_expiry_time 60 seconds'
if grep -xqF "${DENY_ALL}" ${SQUID_CONF}
then
	echo "Setting Squid proxy server"
	sudo sed -i "s/^${SQUID_DENY_ALL}$/#${SQUID_DENY_ALL}\nhttp_access allow all/g" ${SQUID_CONF}
	sudo sed -i "s/^${SQUID_OBJ_SIZE}$/${SQUID_OBJ_SIZE}\nmaximum_object_size 1 GB/g" ${SQUID_CONF}
	sudo sed -i "s/^${SQUID_EXP_TIME}$/${SQUID_EXP_TIME}\nminimum_expiry_time 600 seconds/g" ${SQUID_CONF}
	sudo service squid restart
else
	sudo service squid start
fi


source common_vars.sh

PASSWD=$( enter_pwd "sudo system user ${HOST_USER}" )

echo ""
echo "Set this adress as Proxy Server in targets:"
echo "http://${NET_IP}:3128/"
echo ""
read -p 'Press [Enter] key to continue...'

#LIST_IPS=$( sudo nmap -p 22 -Pn -oG - "${NET_MASK}" | awk '/open/{print $2}' )
LIST_IPS=$( grep 'ansible_host' ${ALL_FILE_HOSTS} | cut -d= -f2 )
#LIST_MACS=$( awk '/ansible_host/{print $1}' ${ALL_FILE_HOSTS} )
echo ""
echo "Loaded IPs from ${ALL_FILE_HOSTS}"
echo "${LIST_IPS}"
echo ""

PASSPHRASE=''	# $( passphrase )
echo "Passphrase to unlock private key: '${PASSPHRASE}'"

rm -rf ${ROOT_PATH_KEYS}
mkdir -p ${ROOT_PATH_KEYS}
#rm -f ${FILE_EXTRA_VARS}
#rm -f ${PATH_SSH_KEYS}*
rm -f ~/.ssh/known_hosts
sudo service ssh restart
./expect_ssh-keygen.sh "${PASSPHRASE}" "${PATH_SSH_KEYS}" "$(whoami)@$(hostname)-$(date -I)"

sudo service ssh restart

echo "[${HOSTS}]" > ${VALID_FILE_HOSTS}
for HOST_IP in ${LIST_IPS}; do
	HOST_MAC=$( grep "ansible_host=${HOST_IP}$" ${ALL_FILE_HOSTS} | awk '{print $1}' )
	HOST_SSH=$( nmap -p 22 -Pn -oG - ${HOST_IP} | awk '/open/{print $2}' )
	if [ -z "${HOST_SSH}" ]; then
		echo "ERROR without ssh at host ${HOST_IP} (${HOST_MAC})"
	else
		echo "setting ${HOST_IP} (${HOST_MAC}) ..."
		./expect_ssh-copy.sh "${HOST_USER}" "${HOST_IP}" "${PASSWD}" "${PATH_SSH_KEYS}"
		if [ $? -eq 0 ]; then
			echo -e "SUCCESS ssh-copy to host IP: ${HOST_IP}\tMAC-ADDRESS: ${HOST_MAC}"
			echo -e "${HOST_MAC}\tansible_host=${HOST_IP}" >> ${VALID_FILE_HOSTS}
		else
			echo "ERROR on ssh-copy to host ${HOST_IP} (${HOST_MAC})"
		fi
	fi
done

echo ""
echo "======================================================="
echo "show ${VALID_FILE_HOSTS}"
echo "======================================================="
grep -n '^' ${VALID_FILE_HOSTS}
echo "======================================================="
echo ""
