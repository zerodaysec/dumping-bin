#!/bin/bash

IFACE_OUT=""
IFACE_IN=""

if [ ! "$IFACE_OUT" == "" ]
then
	IPT_IFACE_OUT="-o $IFACE_OUT"
fi

if [ ! "$IFACE_IN" == "" ]
then
	IPT_IFACE_IN="-i $IFACE_IN"
fi

### Incoming Functions

incoming_tcp(){
# Allow incoming tcp on $1
iptables -A INPUT $IPT_IFACE_IN -p tcp --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT $IPT_IFACE_OUT -p tcp --sport $1 -m state --state ESTABLISHED -j ACCEPT
}

incoming_udp(){
# Allow incoming tcp on $1
iptables -A INPUT $IPT_IFACE_IN -p udp --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT $IPT_IFACE_OUT -p udp --sport $1 -m state --state ESTABLISHED -j ACCEPT
}

incoming_http(){
incoming_tcp 80

# Prevent DoS on Webserver limits to 25 / min after 100 burst
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
}

incoming_https(){
incoming_tcp 443

# Prevent DoS on Webserver limits to 25 / min after 100 burst
iptables -A INPUT -p tcp --dport 443 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
}

incoming_mysql(){ incoming_tcp 3306; }
incoming_smtp(){ incoming_tcp 25; }
incoming_ssh(){ incoming_tcp 8022; }
incoming_imap(){ incoming_tcp 143; }
incoming_imaps(){ incoming_tcp 993; }

### Outbound Functions

outbound_tcp(){
# Allow outgoing tcp $1
iptables -A OUTPUT $IPT_IFACE_OUT -p tcp --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT $IPT_IFACE_IN -p tcp --sport $1 -m state --state ESTABLISHED -j ACCEPT
}

outbound_udp(){
# Allow outgoing tcp $1
iptables -A OUTPUT $IPT_IFACE_OUT -p udp --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT $IPT_IFACE_IN -p udp --sport $1 -m state --state ESTABLISHED -j ACCEPT
}

outbound_dns(){ outbound_udp 53;}
outbound_http(){ outbound_tcp 80; }
outbound_https(){ outbound_tcp 443; }
outbound_ssh(){ outbound_tcp 22; }
outbound_smtp(){ outbound_tcp 25; }

### ICMP Functions

ping_inside2outside(){
# Allow Ping from Inside to Outside
iptables -A OUTPUT $IPT_IFACE_OUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT $IPT_IFACE_IN  -p icmp --icmp-type echo-reply -j ACCEPT
}

ping_outside2inside(){
# Allow Ping from Inside to Outside
iptables -A INPUT $IPT_IFACE_IN -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT $IPT_IFACE_OUT -p icmp --icmp-type echo-reply -j ACCEPT
}


### Misc Functions

allow_lo(){
# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
}

force_sync_check(){
# Force SYN packets check
# Make sure new incoming tcp connections are SYN packets else drop them
iptables -A INPUT $IPT_IFACE_IN -p tcp ! --syn -m state --state NEW -j DROP
}

drop_null(){
# Drop null packets
iptables -A INPUT $IPT_IFACE_IN -p tcp --tcp-flags ALL NONE -j DROP
}

setup_logging(){
#LOGGING
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
iptables -A LOGGING -j DROP
}


################################################################################
############### Below is where you apply the above rules / funcs ###############
################################################################################

########################################
# Default Chain Actions
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Initial setup...
force_sync_check
drop_null
allow_lo

### Incoming
#ping_outside2inside
incoming_ssh

### Outgoing
outbound_dns
outbound_ssh
outbound_https
outbound_http
ping_inside2outside

### Logging
setup_logging

/root/country-block-iptables.sh
