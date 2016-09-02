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
echo -e "You need a real ${YELLOW}ip address.${NC}"
echo -e "You need to be able to ping the ${YELLOW}default gateway.${NC}"
echo -e "You need to have a ${YELLOW}DNS server.${NC}"
echo -e "You need to be able ${YELLOW}to route to the DNS server.${NC}"
echo -e "You need ${YELLOW}DNS lookups to complete.${NC}"
echo "You need those DNS lookups to work quickly."
echo "this script just checks everything."
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
publicIP=$(dig +short myip.opendns.com @resolver1.opendns.com)

#if Ip address starts with 169.254, it's probably a self configured address and it suggests a problem.  
if [[ $ipaddress == 169.254.* ]]; then
    echo $ipaddress " is a self-assigned address and suggests something isn't working with DHCP."
    echo "Go read https://technet.microsoft.com/en-us/library/cc958902.aspx on windows"
    echo "Go read http://osxdaily.com/2013/02/11/renew-dhcp-lease-mac-os-x/ on a mac"
else
    echo "Your local IP address is:" $ipaddress 
fi
echo "Your Public IP address is:" $publicIP
echo "Your netmask is:" $netmask
echo "Your default gateway is:" $dgw
echo "Your nameserver is:" $ns


echo ""
echo "***********************************************************"
echo "Ping tests for local network testing"
echo "***********************************************************"
echo "Ping response from default gateway"
response=$(ping -c 1 $dgw | grep time=)
if [ -z "$response" ]; then
    echo -e "${RED}ERROR: couldn't ping the default gateway.${NC}  This might not be a big deal- firewalls can block ping requests." 
    echo "If DNS pings don't work, you need to troubleshoot this first.  Do a DHCP renew and try again.  If that fails, reboot your router."
else
    echo $response
fi

echo "ping response from your nameserver($ns)"
response=$(ping -c 1 $ns | grep time=)
if [ -z "$response" ]; then
    echo -e "${RED}ERROR: couldn't ping the nameserver.${NC}  If the nameserver is outside your home, you may want to try rebooting your cable/dsl modem."
else
    echo $response
fi
echo "Ping response from google nameserver(8.8.4.4)"
response=$(ping -c 1 8.8.4.4 | grep time=)
if [ -z "$response" ]; then
    echo -e "${RED}ERROR: couldn't ping the google's nameserver.${NC}  If your ISP DNS server & this one aren't reachable, the problem may be at your ISP"
else
    echo $response
fi
echo ""
echo "***********************************************************"
echo "DNS tests:"
echo "***********************************************************"
localNSQueryTime=$(dig @$ns google.com | grep Query)
googNSQueryTime=$(dig @8.8.4.4 google.com | grep Query)
echo "Your preconfigured DNS ($ns) querytime:" $localNSQueryTime
echo "Compare this to google's DNS (8.8.4.4) time:" $googNSQueryTime
