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
if grep -xqF "${SQUID_DENY_ALL}" ${SQUID_CONF}
then
	echo "Setting Squid proxy server"
	sudo sed -i "s/^${SQUID_DENY_ALL}$/#${SQUID_DENY_ALL}\nhttp_access allow all/g" ${SQUID_CONF}
	sudo sed -i "s/^${SQUID_OBJ_SIZE}$/${SQUID_OBJ_SIZE}\nmaximum_object_size 1 GB/g" ${SQUID_CONF}
	#sudo sed -i "s/^${SQUID_EXP_TIME}$/${SQUID_EXP_TIME}\nminimum_expiry_time 0 seconds/g" ${SQUID_CONF}
	sudo service squid restart
else
	sudo service squid start
fi

source net_vars.sh

echo ""
echo "Set this adress as Proxy Server in targets:"
echo "http://${NET_IP}:3128/"
echo ""
read -p 'Press [Enter] key to continue...'
