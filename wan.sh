#!/bin/bash -x

#VARIABLES
IT_WAN=enp0s3
IT_EXT=enp0s8
IT_INT=enp0s8 

IP_WAN=10.0.2.100
IP_EXT=192.168.5.100
IP_INT=192.168.5.101

NET_G=192.168.0.0/16
NET_INT=192.168.5.0/24

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
iptables -t mangle -P POSTROUTING ACCEPT
iptables -t mangle -P OUTPUT ACCEPT
iptables -t mangle -P INPUT ACCEPT
iptables -t mangle -P FORWARD ACCEPT


#CadenasUsuarios
#forwardings
iptables -N int_to_wan
iptables -N wan_to_int

#inputs
iptables -N ext_to_int
iptables -N wan_to_ext
#outputs
iptables -N int_to_ext
iptables -N ext_to_wan

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
iptables -A wan_to_ext -p udp --dport 123 --sport 123 -j ACCEPT
iptables -A ext_to_wan -p udp --dport 123 --sport 123 -j ACCEPT


#DNSCHECK
iptables -A ext_to_wan -p udp --dport 53 -j dnscheck
iptables -A ext_to_wan -p tcp --dport 53 -j dnscheck
iptables -A int_to_wan -p udp --dport 53 -j dnscheck
iptables -A int_to_wan -p tcp --dport 53 -j dnscheck


#DNSLISTABLANCA
iptables -A dnscheck -m set --match-set whitelist dst -j ACCEPT
iptables -A dnscheck -j REJECT


#LISTANEGRA
iptables -I INPUT -m set --match-set badlist src -j DROP
iptables -I FORWARD -m set --match-set badlist src -j DROP


#NATCONF
iptables -t nat -A POSTROUTING -o $IT_WAN -j MASQUERADE


#ACEPTARELTRAFICO
iptables -A ext_to_int -j ACCEPT
iptables -A ext_to_wan -j ACCEPT

#DNAT
iptables -t nat -A PREROUTING -p tcp --dport 2223 -j DNAT --to-destination ${IP_INT}:22
iptables -t nat -A PREROUTING -p tcp --dport 2224 -j DNAT --to-destination ${IP_INT}:2224
iptables -A wan_to_int -p tcp --dport 2223 -d $IP_INT -j ACCEPT
iptables -A wan_to_int -p tcp --dport 2224 -d $IP_INT -j ACCEPT

#ACEPTANDOPUERTOS
iptables -A wan_to_ext -p tcp --dport 22 -j ACCEPT
iptables -A wan_to_int -p tcp --dport 22 -j ACCEPT
iptables -A int_to_wan -p tcp --match multiport --dports 21:23,80 -j ACCEPT


#LOOPBACK
iptables -A INPUT -i lo -m state --state NEW -j ACCEPT
iptables -A OUTPUT -o lo -m state --state NEW -j ACCEPT



#Clasificación

iptables -A FORWARD -m state --state NEW -i $IT_INT -o $IT_WAN -s $NET_G -j int_to_wan
iptables -A FORWARD -m state --state NEW -i $IT_WAN -o $IT_INT -d $NET_INT -j wan_to_int

iptables -A INPUT -m state --state NEW -i $IT_WAN -d $IP_WAN -j wan_to_ext
iptables -A INPUT -m state --state NEW -i $IT_INT -s $NET_INT -d $IP_INT -j int_to_ext

iptables -A OUTPUT -m state --state NEW -o $IT_WAN -j ext_to_wan
iptables -A OUTPUT -m state --state NEW -o $IT_INT -j ext_to_int


#ACTIVAMOSFORWARDING
echo 1 > /proc/sys/net/ipv4/ip_forward
#sysctl --system 
#iptables-save > /etc/iptables/rules.v4

