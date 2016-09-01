#!/bin/bash

function pause(){
	read -p "$*"
}
RED='\033[0;31m'
NC='\033[0m' # NOCOLOR
YELLOW='\033[0;33m'

function HexToDotted (){
     echo $1 | sed 's/0x// ; s/../& /g' | tr [:lower:] [:upper:] | while read B1 B2 B3 B4 ; do
         echo "ibase=16;$B1;$B2;$B3;$B4" | bc | tr '\n' . | sed 's/\.$//'
done
}

echo "***********************************************************"
echo " "
echo "There are 6 things that need to work for internet."
echo "You need a real ip address."
echo "You need to be able to ping the default gateway."
echo "You need to have a DNS server."
echo "You need to be able to route to it."
echo "You need DNS lookups to complete."
echo "You need those DNS lookups to work quickly."
echo "this script just fucking checks everything."
echo ""
echo "***********************************************************"
echo " "
ipaddress=$(ifconfig en0 | grep "inet " 2>&1)
#	inet 192.168.43.223 netmask 0xffffff00 broadcast 192.168.43.255

#IFS=$'\n'
arr=($(ifconfig en0 | grep "inet " 2>&1))
#unset IFS

#unnecessary way to strip white text from array 1 entry: (echo ${arr[1]})| awk '{$1=$1;print}'

ipaddress=${arr[1]}
netmask=${arr[3]}
netmask=$(HexToDotted $netmask)
broadcast=${arr[5]}
ns=$(networksetup -getdnsservers Wi-Fi)
dgw=$(route -n get default | sed -n -e 's/^.*gateway: //p')

echo "Your IP address is:" $ipaddress 
echo "Your netmask is:" $netmask
echo "Your default gateway is:" $dgw
echo "Your nameserver is:" $ns

echo ""
echo "Ping response from default gateway"
ping -c 1 $dgw
echo ""
echo "ping response from your nameserver"
ping -c 1 $ns
echo ""
echo "Ping response from google nameserver"
ping -c 1 8.8.4.4
echo ""
echo "NSLookup test"
dig google.com $ns
echo "nslookup test against google nameserver"
dig google.com 8.8.4.4
