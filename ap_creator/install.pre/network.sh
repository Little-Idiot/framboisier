#!/bin/bash
[[ 0 -ne $EUID ]] && { printf "usage: sudo $0\n"; exit -1; }
printf "script: $0\n"



################################################################################
# network: settings
################################################################################
readonly net_eth0_mac=$(printf "02\:%02x\:%02x\:%02x\:%02x\:%02x" $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])
readonly net_eth0_ip=""

readonly net_wlan0_mac=$(printf "02\:%02x\:%02x\:%02x\:%02x\:%02x" $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])
readonly net_wlan0_ip="172.16.30.1/27"



################################################################################
# network: configuration eth0
################################################################################
[[ ! -f install.pre/ressources/eth0.network.template ]] && { printf "error: file \"install.pre/ressources/eth0.network.template\" missing\n"; exit -2; }

cp install.pre/ressources/eth0.network.template /etc/systemd/network/eth0.network

sed -i "s:<address_mac>:$net_eth0_mac:g" /etc/systemd/network/eth0.network



################################################################################
# network: configuration wlan0
################################################################################
[[ ! -f install.pre/ressources/wlan0.network.template ]] && { printf "error: file \"install.pre/ressources/wlan0.network.template\" missing\n"; exit -3; }

cp install.pre/ressources/wlan0.network.template /etc/systemd/network/wlan0.network

sed -i "s:<address_mac>:$net_wlan0_mac:g" /etc/systemd/network/wlan0.network
sed -i "s:<address_ip>:$net_wlan0_ip:g" /etc/systemd/network/wlan0.network



################################################################################
# network: enable ipv4 forwarding
################################################################################
printf "net.ipv4.ip_forward = 1\n" >> /etc/sysctl.d/99-sysctl.conf

systemctl restart systemd-sysctl
[[ 0 -ne $? ]] && { printf "error: fail to reload kernel parameters at runtime"; exit -4; }



################################################################################
# network: daemon
################################################################################
systemctl restart systemd-networkd
[[ 0 -ne $? ]] && { printf "error: fail to restart \"systemd-network\" daemon (exit: $?)\n"; exit -5; }



exit 0
