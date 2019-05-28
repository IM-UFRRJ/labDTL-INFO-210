#!/bin/bash

source net_vars.sh

echo "[${HOSTS}]" > ${ALL_FILE_HOSTS}

arp -e -n -i "${NET_IFACE}" | grep -v "HWaddress\|incomplete" | \
   awk -v out_file=${ALL_FILE_HOSTS} '{ print $3"\tansible_host="$1 >> out_file; }'

for IGNORE_IP in ${IGNORE_IPS}; do
   echo "ignoring IP: ${HOST_IP}"
   sed -i "/${IGNORE_IP}$/d" ${ALL_FILE_HOSTS}
done

echo ""
echo "======================================================="
echo "cat ${ALL_FILE_HOSTS}"
echo "======================================================="
cat ${ALL_FILE_HOSTS}
echo "======================================================="
echo ""
