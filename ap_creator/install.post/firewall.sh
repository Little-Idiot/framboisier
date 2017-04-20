#!/bin/bash
[[ 0 -ne $EUID ]] && { printf "usage: sudo $0\n"; exit -1; }
printf "script: $0\n"



################################################################################
# iptables: settings
################################################################################
readonly fw_lan_if="eth0"
readonly fw_lan_subnet=""

readonly fw_wlan_if="wlan0"
readonly fw_wlan_subnet="172.16.30.0/27"

readonly fw_vpn_if="tun0"
readonly fw_vpn_subnet=""



################################################################################
# iptables: flush (old) rules
################################################################################
iptables --table filter --flush INPUT
iptables --table filter --flush OUTPUT
iptables --table filter --flush FORWARD

# ip6tables --table filter --flush INPUT
# ip6tables --table filter --flush OUTPUT
# ip6tables --table filter --flush FORWARD



################################################################################
# iptables: set default policies
################################################################################
iptables --table filter --policy INPUT DROP
iptables --table filter --policy OUTPUT DROP
iptables --table filter --policy FORWARD DROP

# ip6tables --table filter --policy INPUT DROP
# ip6tables --table filter --policy OUTPUT DROP
# ip6tables --table filter --policy FORWARD DROP



################################################################################
# iptables: lan
################################################################################

# dhcp
iptables --table filter --append INPUT --jump ACCEPT --in-interface $fw_lan_if --protocol udp --sport 67 --dport 68
iptables --table filter --append OUTPUT --jump ACCEPT --out-interface $fw_lan_if --protocol udp --sport 68 --dport 67

# dns
iptables --table filter --append INPUT --jump ACCEPT --in-interface $fw_lan_if --protocol udp --sport 53
iptables --table filter --append OUTPUT --jump ACCEPT --out-interface $fw_lan_if --protocol udp --dport 53

# http
iptables --table filter --append INPUT --jump ACCEPT --in-interface $fw_lan_if --protocol tcp --sport 80 -m state --state ESTABLISHED
iptables --table filter --append OUTPUT --jump ACCEPT --out-interface $fw_lan_if --protocol tcp --dport 80 -m state --state ESTABLISHED,NEW

# ssh
iptables --table filter --append INPUT --jump ACCEPT --in-interface $fw_lan_if --protocol tcp --dport 22 -m state --state ESTABLISHED,NEW
iptables --table filter --append OUTPUT --jump ACCEPT --out-interface $fw_lan_if --protocol tcp --sport 22 -m state --state ESTABLISHED,NEW



################################################################################
# iptables: wlan
################################################################################

# nat
iptables --table nat --append POSTROUTING --jump MASQUERADE --out-interface $fw_lan_if --source $fw_wlan_subnet

# dhcp
iptables --table filter --append INPUT --jump ACCEPT --in-interface $fw_wlan_if --protocol udp --sport 68 --dport 67
iptables --table filter --append OUTPUT --jump ACCEPT --out-interface $fw_wlan_if --protocol udp --sport 67 --dport 68

# dns
iptables --table filter --append FORWARD --jump ACCEPT --in-interface $fw_lan_if --out-interface $fw_wlan_if --protocol udp --sport 53
iptables --table filter --append FORWARD --jump ACCEPT --in-interface $fw_wlan_if --out-interface $fw_lan_if --protocol udp --dport 53

# http
iptables --table filter --append FORWARD --jump ACCEPT --in-interface $fw_lan_if --out-interface $fw_wlan_if --protocol tcp --sport 80 -m state --state ESTABLISHED
iptables --table filter --append FORWARD --jump ACCEPT --in-interface $fw_wlan_if --out-interface $fw_lan_if --protocol tcp --dport 80 -m state --state ESTABLISHED,NEW

# https
iptables --table filter --append FORWARD --jump ACCEPT --in-interface $fw_lan_if --out-interface $fw_wlan_if --protocol tcp --sport 443 -m state --state ESTABLISHED
iptables --table filter --append FORWARD --jump ACCEPT --in-interface $fw_wlan_if --out-interface $fw_lan_if --protocol tcp --dport 443 -m state --state ESTABLISHED,NEW



################################################################################
# iptables: enable
################################################################################
iptables-save > /etc/iptables/iptables.rules

systemctl enable iptables
[[ 0 -ne $? ]] && { printf "error: fail to enable \"iptables\" daemon (exit: $?)"; exit -2; }



exit 0
