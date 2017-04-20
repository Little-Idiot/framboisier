#!/bin/bash
[[ 0 -ne $EUID ]] && { printf "usage: sudo $0\n"; exit -1; }



################################################################################
# setup: install.pre
################################################################################
[[ ! -f install.pre/network.sh ]] && { printf "error: file \"install.pre/network.sh\" missing\n"; exit -2; }

./install.pre/network.sh || { printf "error: script \"install.pre/network.sh\" failed (exit: $?)\n"; exit -3; }



################################################################################
# setup: hostapd
################################################################################
[[ ! -f hostapd/setup.sh ]] && { printf "error: file \"hostapd/setup.sh\" missing\n"; exit -4; }

./hostapd/setup.sh || { printf "error: script \"hostapd/setup.sh\" failed (exit: $?)\n"; exit -5; }



################################################################################
# setup: dnsmasq
################################################################################
[[ ! -f dnsmasq/setup.sh ]] && { printf "error: file \"dnsmasq/setup.sh\" missing\n"; exit -6; }

./dnsmasq/setup.sh || { printf "error: script \"dnsmasq/setup.sh\" failed (exit: $?)\n"; exit -7; }
 
 
 
################################################################################
# setup: install.post
################################################################################
[[ ! -f install.post/firewall.sh ]] && { printf "error: file \"install.post/system.sh\" missing\n"; exit -10; }

./install.post/firewall.sh || { printf "error: script \"install.post/firewall.sh\" failed (exit: $?)\n"; exit -11; }



printf "info: setup completed (-> reboot)\n"
exit 0
