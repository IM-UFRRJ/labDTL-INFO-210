#!/bin/bash

# em cada PC remoto, logo após a instalação limpa do ubuntu desktop LTS
#ip a ## anotar o IP
#sudo apt install openssh-client openssh-server -y


# no PC administrador
if ! grep -q "^deb .*ansible" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
	sudo add-apt-repository ppa:ansible/ansible
	sudo apt update
fi
sudo apt install ansible expect nmap squid -y

SQUID_CONF="/etc/squid/squid.conf"
DENY_ALL="http_access deny all"
if grep -xqF "${DENY_ALL}" ${SQUID_CONF}
then
	echo "Setting Squid proxy server"
	sudo sed -i "s/^${DENY_ALL}$/#${DENY_ALL}\nhttp_access allow all/g" ${SQUID_CONF}
	sudo service squid restart
else
	sudo service squid start
fi

source common_vars.sh

PASSWD=$( enter_pwd "sudo system user ${HOST_USER}" )

IGNORE_IPS="${NET_IP} ${DEF_GATEWAY}"

echo ""
echo "Set this adress as Proxy Server in targets:"
echo "http://${NET_IP}:3128/"
echo ""
read -p 'Press [Enter] key to continue...'

LIST_IPS=$( sudo nmap -p 22 -Pn -oG - "${NET_IP}/24" | awk '/open/{print $2}' )
echo "Scanned IPs:"
echo "${LIST_IPS}"

PASSPHRASE=''	# $( passphrase )
echo "Passphrase to unlick private key: '${PASSPHRASE}'"

rm -rf ${ROOT_PATH_KEYS}
mkdir -p ${ROOT_PATH_KEYS}
#rm -f ${FILE_EXTRA_VARS}
#rm -f ${PATH_SSH_KEYS}*
rm -f ~/.ssh/known_hosts
sudo service ssh restart
./expect_ssh-keygen.sh "${PASSPHRASE}" "${PATH_SSH_KEYS}" "$(whoami)@$(hostname)-$(date -I)"

sudo service ssh restart

echo "[${HOSTS}]" > ${ALL_FILE_HOSTS}
for HOST_IP in ${LIST_IPS}; do
	if [[ $IGNORE_IPS =~ (^|[[:space:]])${HOST_IP}($|[[:space:]]) ]]; then
		echo "ignoring IP: ${HOST_IP}"
	else
		echo "setting ${HOST_IP} ..."
		./expect_ssh-copy.sh "${HOST_USER}" "${HOST_IP}" "${PASSWD}" "${PATH_SSH_KEYS}"
		echo "${HOST_IP}" >> ${ALL_FILE_HOSTS}
	fi
done

