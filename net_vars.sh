#!/bin/bash




HOSTS="dskDTL"
FILE_HOSTS="hosts_${HOSTS}"
FILE_IFACE="hosts_iface_${HOSTS}"
ALL_FILE_HOSTS="${FILE_HOSTS}_all"
VALID_FILE_HOSTS="${FILE_HOSTS}_valid"

NET_IFACES=$(ip addr show | awk '/inet.*brd/{print $NF}')
function show_menu_ifaces {
   SAVEIFS=$IFS   # Save current IFS
   IFS=$'\n'      # Change IFS to new line
   NET_IFACES=($NET_IFACES) # split to array $names
   IFS=$SAVEIFS   # Restore IFS
   local netiface
   select netiface in "${NET_IFACES[@]}"; do
      echo $netiface
      break
   done
}

if [ ! -f ${FILE_IFACE} ] ; then
   echo ""
   ip addr show | awk '/inet.*brd/{ print $NF"\t"$2 }'
   echo ""
   echo "Choose the network interface option to use:"
   while true; do
      option=$(show_menu_ifaces)
      if [[ -n $option ]]; then
         echo "Chosen iface: $option"
         break
      else
         echo "Invalid option! Retry..."
      fi
   done
   NET_IFACE=$option #$(ip addr show | awk '/inet.*brd/{print $NF; exit}')
   echo ${NET_IFACE} > ${FILE_IFACE}
else
   NET_IFACE=$(cat ${FILE_IFACE})
fi

NET_MASK=$(ip -o -4 addr list "${NET_IFACE}" | awk '{print $4}')
NET_IP=$(echo ${NET_MASK} | cut -d/ -f1)
DEF_GATEWAY=$(ip route | grep "${NET_IFACE}" | awk '/default/ { print $3 }')
echo -e "\n${NET_IFACE}\t${NET_MASK}\t${NET_IP}\t${DEF_GATEWAY}\n"

IGNORE_IPS="${NET_IP} ${DEF_GATEWAY}"

FILE_LIST_MACS='lists_hosts_macs.txt'
FILE_LIST_IPS="${FILE_LIST_HOSTS/'macs'/'ips'}"
FILE_LIST_HOSTS="${FILE_LIST_HOSTS/'_macs'/''}"
