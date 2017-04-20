#!/bin/bash
[[ 0 -ne $EUID ]] && { printf "usage: sudo $0\n"; exit -1; }
printf "script: $0\n"



################################################################################
# dnsmasq: settings
################################################################################
readonly dhcp_interface="wlan0"
readonly dhcp_address="172.16.30.1"
readonly dhcp_range="172.16.30.10"
readonly dhcp_mask="255.255.255.224"



################################################################################
# dnsmasq: installation
################################################################################
if [ ! -f /etc/dnsmasq.conf ]; then

	pacman --sync --noconfirm dnsmasq &> dnsmasq/pacman.log
	[[ 0 -ne $? ]] && { printf "error: fail to install \"dnsmasq\" (exit: $?)\n"; exit -2; }

fi



################################################################################
# dnsmasq: configuration
################################################################################
[[ ! -f dnsmasq/ressources/dnsmasq.conf.template ]] && { printf "error: file \"dnsmasq/ressources/dnsmasq.conf.template\" missing\n"; exit -3; }

cp dnsmasq/ressources/dnsmasq.conf.template /etc/dnsmasq.conf

sed -i "s:<dhcp_interface>:$dhcp_interface:g" /etc/dnsmasq.conf
sed -i "s:<dhcp_address>:$dhcp_address:g" /etc/dnsmasq.conf
sed -i "s:<dhcp_range>:$dhcp_range:g" /etc/dnsmasq.conf
sed -i "s:<dhcp_mask>:$dhcp_mask:g" /etc/dnsmasq.conf

sed -i "s:ExecStart=/usr/bin/dnsmasq:& --no-resolv:" /usr/lib/systemd/system/dnsmasq.service



################################################################################
# dnsmasq: activation
################################################################################
systemctl start dnsmasq &>> dnsmasq/systemctl.log
[[ 0 -ne $? ]] && { printf "error: fail to start \"dnsmasq\" daemon (exit: $?)\n"; exit -4; }

systemctl enable dnsmasq &>> dnsmasq/systemctl.log
[[ 0 -ne $? ]] && { printf "error: fail to enable \"dnsmasq\" daemon (exit: $?)\n"; exit -5; }



exit 0
