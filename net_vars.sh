#!/bin/bash

#NET_IFACE="wlp2s0"
#NET_IFACE="enp1s0"
#NET_IFACE=$(ip addr show | awk '/inet.*brd/{print $NF}')
NET_IFACE=$(ip addr show | awk '/inet.*brd/{print $NF; exit}')
NET_IP=$(ip -o -4 addr list "${NET_IFACE}" | awk '{print $4}' | cut -d/ -f1)
DEF_GATEWAY=$(ip route | grep "${NET_IFACE}" | awk '/default/ { print $3 }')
NET_MASK="${NET_IP}/24"
