#!/bin/bash


sudo apt install nmap nbtscan samba-common-bin -y

source common_vars.sh

nbtscan "${NET_IP}/24"	# TODO listar MACs e HOSTNAMES
#nmblookup -A 11.0.0.107
