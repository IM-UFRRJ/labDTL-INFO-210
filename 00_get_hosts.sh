#!/bin/bash

source net_vars.sh

echo "[${HOSTS}]" > ${ALL_FILE_HOSTS}

nmap -p 22 -Pn -oG - ${NET_MASK}

arp -e -n -i "${NET_IFACE}" | grep -v "HWaddress\|incomplete" | \
   awk -v out_file=${ALL_FILE_HOSTS} '{ print $3"\tansible_host="$1 >> out_file; }'

for IGNORE_IP in ${IGNORE_IPS}; do
   echo "ignoring IP: ${IGNORE_IP}"
   sed -i "/${IGNORE_IP}$/d" ${ALL_FILE_HOSTS}
done

echo ""
echo "======================================================="
echo "show ${ALL_FILE_HOSTS}"
echo "======================================================="
grep -n '^' ${ALL_FILE_HOSTS}
echo "======================================================="
echo ""
