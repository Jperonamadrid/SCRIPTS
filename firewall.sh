#!/bin/bash -x

#VARIABLES

IT_EXTERIOR=enp0s3
IT_LAN=enp0s8

IP_EXT=192.168.5.101
IP_INT=192.168.6.100
IP_LAN=192.168.6.101


NET_LAN=192.168.6.0/24

SYN_LIMIT=5/s
SYN_BURST=10

SSH_LIMIT=2/s
SSH_BURST=4




#disable routing: see /etc/sysctl.conf
echo 0 > /proc/sys/net/ipv4/ip_forward


#VaciandoTablas
iptables -F -t filter
iptables -X -t filter
iptables -Z -t filter

iptables -F -t nat
iptables -X -t nat
iptables -Z -t nat

iptables -F -t mangle
iptables -X -t mangle
iptables -Z -t mangle

#Politicas
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT

iptables -t mangle -P PREROUTING ACCEPT
iptables -t mangle -P PREROUTING ACCEPT
iptables -t mangle -P POSTROUTING ACCEPT
iptables -t mangle -P OUTPUT ACCEPT
iptables -t mangle -P INPUT ACCEPT
iptables -t mangle -P FORWARD ACCEPT


#CadenasUsuarios
#forwardings
iptables -N lan_to_ext
iptables -N ext_to_lan

#inputs
iptables -N int_to_lan
iptables -N ext_to_int
#outputs
iptables -N lan_to_int
iptables -N int_to_ext

#CadenaDeAtaques
iptables -N newnotsyn
iptables -N dnscheck
iptables -N synflood
iptables -N sshflood
iptables -N pingdeath
iptables -N portscan
iptables -N icmpcheck


#SiempreActivadas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT


#if SYN and not RST,ACK test if it is a synflood
iptables -A INPUT -p tcp --tcp-flags SYN,RST,ACK SYN -j synflood
iptables -A FORWARD -p tcp --tcp-flags SYN,RST,ACK SYN -j synflood

#Limitacion del numero SYN
iptables -A synflood -m limit --limit $SYN_LIMIT --limit-burst $SYN_BURST -j RETURN
iptables -A synflood -j LOG --log-level info --log-prefix I:synflood:
iptables -A synflood -j DROP

#if SYN and not RST,ACK test if it is a synflood
iptables -A INPUT -p tcp --dport 22 --tcp-flags SYN,RST,ACK SYN -j sshflood
iptables -A FORWARD -p tcp --dport 22 --tcp-flags SYN,RST,ACK SYN -j sshflood

#PingOfDeath
iptables -A INPUT -p icmp --icmp-type echo-request -j pingdeath
iptables -A FORWARD -p icmp --icmp-type echo-request -j pingdeath

iptables -A pingdeath -m limit --limit 5/s --limit-burst 15 -j RETURN
iptables -A pingdeath -j LOG --log-level info --log-prefix iptables:pingdeath:
iptables -A pingdeath -j DROP

#port scan
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j portscan
iptables -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j portscan

iptables -A portscan -m limit --limit 128/s --limit-burst 256 -j RETURN
iptables -A portscan -j LOG --log-level info --log-prefix iptables:portscan:
iptables -A portscan -j DROP

#new-not-syn
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j newnotsyn
iptables -A FORWARD -p tcp ! --syn -m state --state NEW -j newnotsyn

iptables -A newnotsyn -j LOG --log-level info --log-prefix iptables:NuevoNoSyn:
iptables -A newnotsyn -j RETURN

#QuitarTraficoInvalido
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP

#ICMP

iptables -A INPUT -p icmp -j icmpcheck
iptables -A OUTPUT -p icmp -j icmpcheck
iptables -A FORWARD -p icmp -j icmpcheck

iptables -A icmpcheck -p icmp --icmp-type 3/4 -j ACCEPT
iptables -A icmpcheck -p icmp --icmp-type 3/3 -j ACCEPT
iptables -A icmpcheck -p icmp --icmp-type 3/1 -j ACCEPT
iptables -A icmpcheck -p icmp --icmp-type 4 -j ACCEPT
iptables -A icmpcheck -p icmp -i ${IP_INT} --icmp-type 8 -j ACCEPT
iptables -A icmpcheck -p icmp -j DROP

#NTP
iptables -A ext_to_int -p udp --dport 123 --sport 123 -j ACCEPT
iptables -A int_to_ext -p udp --dport 123 --sport 123 -j ACCEPT
#DNSCHECK
iptables -A int_to_ext -p udp --dport 53 -j dnscheck
iptables -A int_to_ext -p tcp --dport 53 -j dnscheck
iptables -A lan_to_ext -p udp --dport 53 -j dnscheck
iptables -A lan_to_ext -p tcp --dport 53 -j dnscheck


#DNSLISTABLANCA
iptables -A dnscheck -m set --match-set whitelist dst -j ACCEPT
iptables -A dnscheck -j REJECT


#LISTANEGRA
iptables -I INPUT -m set --match-set badlist src -j DROP
iptables -I FORWARD -m set --match-set badlist src -j DROP


#ACEPTARELTRAFICO
iptables -A int_to_lan -j ACCEPT
iptables -A int_to_ext -j ACCEPT

#DNAT
iptables -t nat -A PREROUTING -p tcp --dport 2224 -j DNAT --to-destination ${IP_LAN}:22
iptables -A ext_to_lan -p tcp --dport 2224 -d $IP_LAN -j ACCEPT

#ACEPTANDOPUERTOS
iptables -A ext_to_int -p tcp --dport 22 -j ACCEPT
iptables -A ext_to_lan -p tcp --dport 22 -j ACCEPT
iptables -A lan_to_ext -p tcp --match multiport --dports 21:23,80 -j ACCEPT


#LOOPBACK
iptables -A INPUT -i lo -m state --state NEW -j ACCEPT
iptables -A OUTPUT -o lo -m state --state NEW -j ACCEPT
#Clasificación

iptables -A FORWARD -m state --state NEW -i $IT_LAN -o $IT_EXTERIOR -s $NET_LAN -j lan_to_ext
iptables -A FORWARD -m state --state NEW -i $IT_EXTERIOR -o $IT_LAN -d $NET_LAN -j ext_to_lan

iptables -A INPUT -m state --state NEW -i $IT_EXTERIOR -d $IP_EXT -j ext_to_int
iptables -A INPUT -m state --state NEW -i $IT_LAN -s $NET_LAN -d $IP_LAN -j lan_to_int

iptables -A OUTPUT -m state --state NEW -o $IT_EXTERIOR -j int_to_ext
iptables -A OUTPUT -m state --state NEW -o $IT_LAN -j int_to_lan


#ACTIVAMOSFORWARDING
echo 1 > /proc/sys/net/ipv4/ip_forward
#sysctl --system
#iptables-save > /etc/iptables/rules.v4
