#!/bin/bash
[[ 0 -ne $EUID ]] && { printf "usage: sudo $0\n"; exit -1; }
printf "script: $0\n"



################################################################################
# hostapd: settings
################################################################################
readonly ap_ssid=""
readonly ap_password=""

([[ -z "$ap_ssid" ]] || [[ -z "$ap_password" ]]) && { printf "error: \"ap_ssid\"/\"ap_password undefined\"\n"; exit -2; }

printf "info: ssid=%s\n" "$ap_ssid"
printf "info: password=%s\n" "$ap_password"



################################################################################
# hostapd: installation
################################################################################
if [ ! -d /etc/hostapd ]; then

	pacman --sync --noconfirm hostapd &>> hostapd/pacman.log
	[[ 0 -ne $? ]] && { printf "error: fail to install \"hostapd\" (exit: $?)\n"; exit -3; }

fi



################################################################################
# hostapd: configuration
################################################################################
[[ ! -f hostapd/ressources/hostapd.conf.template ]] && { printf "error: file \"hostapd/ressources/hostapd.conf.template\" missing\n"; exit -4; }

cp hostapd/ressources/hostapd.conf.template /etc/hostapd/hostapd.conf

sed -i "s:<ap_ssid>:$ap_ssid:g" /etc/hostapd/hostapd.conf
sed -i "s:<ap_password>:$ap_password:g" /etc/hostapd/hostapd.conf

sed -i "s:After=.*:After=network-online\.target:g" /usr/lib/systemd/system/hostapd.service



################################################################################
# hostapd: activation
################################################################################
systemctl start hostapd &>> hostapd/systemctl.log
[[ 0 -ne $? ]] && { printf "error: fail to start \"hostapd\" daemon (exit: $?)\n"; exit -5; }

systemctl enable hostapd &>> hostapd/systemctl.log
[[ 0 -ne $? ]] && { printf "error: fail to enable \"hostapd\" daemon (exit: $?)\n"; exit -6; }



exit 0
