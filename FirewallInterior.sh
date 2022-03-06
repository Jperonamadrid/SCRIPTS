#!/bin/bash -x

#VARIABLES

INT_EXTERIOR=enp0s3
INT_LAN=enp0s8

IP_EXTERIOR=172.16.69.69
IP_INTERIOR=172.16.4.21
IP_LAN=172.16.4.20


NET_LAN=192.168.4.0/24

SYN_LIMIT=5/s
SYN_BURST=10

SSH_LIMIT=2/s
SSH_BURST=4




#desactivamos el forwarding mientras estamos haciendo el firewall

echo 0 > /proc/sys/net/ipv4/ip_forward


#Vaciamos las tablas antes de poner nada
iptables -F -t filter
iptables -X -t filter
iptables -Z -t filter

iptables -F -t nat
iptables -X -t nat
iptables -Z -t nat

iptables -F -t mangle
iptables -X -t mangle
iptables -Z -t mangle

#ponemos las politicas en drop como pide en moodle
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


# y empezamos a definir las cadenas de usuarios necesarias para el script 

#forwardings
iptables -N lan_to_exterior
iptables -N exterior_to_lan

#inputs
iptables -N interior_to_lan
iptables -N exterior_to_interior
#outputs
iptables -N lan_to_interior
iptables -N interior_to_exterior

#estas serian las cadenas de usuario que tenemos en los documentos para ataques comunes
iptables -N newnotsyn
iptables -N dnscheck
iptables -N synflood
iptables -N sshflood
iptables -N pingdeath
iptables -N portscan
iptables -N icmpcheck
#tenemos siempre activos los paquetes con estate established y related 


iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# apartir de aqui es un copia y pega de los ataques tipicos sacado de los apuntes que nos has dado 

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

#Muy importante esta regla para quitarlos el trafico invalido (en vez de poner mil reglas para vert que paquetes tienen activo que flags)

iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP

#activamos el icmp y tenemos cuidado tambien del icmp blackhole

iptables -A INPUT -p icmp -j icmpcheck
iptables -A OUTPUT -p icmp -j icmpcheck
iptables -A FORWARD -p icmp -j icmpcheck

iptables -A icmpcheck -p icmp --icmp-type 3/4 -j ACCEPT
iptables -A icmpcheck -p icmp --icmp-type 3/3 -j ACCEPT
iptables -A icmpcheck -p icmp --icmp-type 3/1 -j ACCEPT
iptables -A icmpcheck -p icmp --icmp-type 4 -j ACCEPT
iptables -A icmpcheck -p icmp -i ${IP_INTERIOR} --icmp-type 8 -j ACCEPT
iptables -A icmpcheck -p icmp -j DROP

#Permitimos que pase el ntp por su puerto 

iptables -A ext_to_interior -p udp --dport 123 --sport 123 -j ACCEPT
iptables -A interior_to_exterior -p udp --dport 123 --sport 123 -j ACCEPT
#permitimos tanto la dns normal como la extendida aceptando tanto con tcp como con udp 
iptables -A int_to_exterior -p udp --dport 53 -j dnscheck
iptables -A int_to_exterior -p tcp --dport 53 -j dnscheck
iptables -A lan_to_exterior -p udp --dport 53 -j dnscheck
iptables -A lan_to_exterior -p tcp --dport 53 -j dnscheck


# la whitelist que he escogido 
iptables -A dnscheck -m set --match-set whitelist dst -j ACCEPT
iptables -A dnscheck -j REJECT


## la blacklist que he escogido 

iptables -I INPUT -m set --match-set badlist src -j DROP
iptables -I FORWARD -m set --match-set badlist src -j DROP


#aceptamos el trafico 
iptables -A interior_to_lan -j ACCEPT
iptables -A interior_to_exterior -j ACCEPT

#un simple dnat con su prerouting 
iptables -t nat -A PREROUTING -p tcp --dport 2224 -j DNAT --to-destination ${IP_LAN}:22
iptables -A exterior_to_lan -p tcp --dport 2224 -d $IP_LAN -j ACCEPT

#Aceptamos los puertos 22 (para ssh) y tambien el puerto 21 al 23  (ftp) el 80 y el 443 
#porque si no no podra ni hacer update ni usar ni ftp ni hacer na
iptables -A exterior_to_interior -p tcp --dport 22 -j ACCEPT
iptables -A exterior_to_lan -p tcp --dport 22 -j ACCEPT
iptables -A lan_to_exterior -p tcp --match multiport --dports 21:23,80,443 -j ACCEPT


#aceptaMOS EL TRAFICO DE LA LOOPBACK 
iptables -A INPUT -i lo -m state --state NEW -j ACCEPT
iptables -A OUTPUT -o lo -m state --state NEW -j ACCEPT
#Clasificación 

iptables -A FORWARD -m state --state NEW -i $INT_LAN -o $INT_EXTERIOR -s $NET_LAN -j lan_to_exterior
iptables -A FORWARD -m state --state NEW -i $INT_EXTERIOR -o $INT_LAN -d $NET_LAN -j exterior_to_lan

iptables -A INPUT -m state --state NEW -i $INT_EXTERIOR -d $IP_EXTERIOR -j exterior_to_interior
iptables -A INPUT -m state --state NEW -i $INT_LAN -s $NET_LAN -d $IP_LAN -j lan_to_interior

iptables -A OUTPUT -m state --state NEW -o $INT_EXTERIOR -j interior_to_exterior
iptables -A OUTPUT -m state --state NEW -o $INT_LAN -j interior_to_lan


#ACTIVAMOSFORWARDING
echo 1 > /proc/sys/net/ipv4/ip_forward
#sysctl --system
#iptables-save > /etc/iptables/rules.v4
