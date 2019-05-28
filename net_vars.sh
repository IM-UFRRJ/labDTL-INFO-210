#!/bin/bash

HOSTS="deskDTL"
FILE_HOSTS="hosts_${HOSTS}"
ALL_FILE_HOSTS="${FILE_HOSTS}_all"
VALID_FILE_HOSTS="${FILE_HOSTS}_valid"


#NET_IFACE="wlp2s0"
#NET_IFACE="enp1s0"
#NET_IFACE=$(ip addr show | awk '/inet.*brd/{print $NF}')
NET_IFACE=$(ip addr show | awk '/inet.*brd/{print $NF; exit}')
NET_MASK=$(ip -o -4 addr list "${NET_IFACE}" | awk '{print $4}')
NET_IP=$(echo ${NET_MASK} | cut -d/ -f1)
DEF_GATEWAY=$(ip route | grep "${NET_IFACE}" | awk '/default/ { print $3 }')
echo -e "${NET_IFACE}\t${NET_MASK}\t${NET_IP}\t${DEF_GATEWAY}"

IGNORE_IPS="${NET_IP} ${DEF_GATEWAY}"

FILE_LIST_MACS='lists_hosts_macs.txt'
FILE_LIST_IPS="${FILE_LIST_HOSTS/'macs'/'ips'}"
FILE_LIST_HOSTS="${FILE_LIST_HOSTS/'_macs'/''}"
