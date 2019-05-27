#!/bin/bash


sudo apt install nmap nbtscan samba-common-bin -y

source net_vars.sh

#nbtscan "${NET_MASK}"
#ip neigh show | grep 'STALE\|DELAY\|REACHABLE'

FILE_LIST_HOSTS='lists_hosts_macs.txt'
FILE_LIST_HOSTS_TMP="/tmp/${FILE_LIST_HOSTS/'.txt'/'.tmp'}"

LIST_ALL_IPS_MAC=$( ip neigh show )
#echo "${LIST_ALL_IPS_MAC}" | grep 'STALE\|DELAY\|REACHABLE'

nbtscan "${NET_MASK}" | \
   grep -oP '([0-9]{1,3}[\.]){3}([0-9]{1}).+([0-9a-fA-F]{2}[:-]){5}([0-9a-fA-F]{2})' | \
   awk -v out_file=${FILE_LIST_HOSTS_TMP} '{ print $1"\t"$5"\t"tolower($2) > out_file; }'

rm -rf ${FILE_LIST_HOSTS}
while IFS=$'\t' read -r HOSTIP HOSTMAC HOSTNAME
do
   if [[ -n ${HOSTIP} ]]; then
      echo "${LIST_ALL_IPS_MAC}" | grep -P "${HOSTIP}[\s]+" | \
         awk -v hostip=${HOSTIP} -v hostname=${HOSTNAME} -v out_file=${FILE_LIST_HOSTS} \
            '{ print $5"\t"hostname"\t"hostip >> out_file; }'
   fi
done < "${FILE_LIST_HOSTS_TMP}"

rm -rf ${FILE_LIST_HOSTS_TMP}

echo "===================="
echo "cat ${FILE_LIST_HOSTS}"
cat ${FILE_LIST_HOSTS}
echo "===================="
