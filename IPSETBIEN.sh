#!/bin/bash 
# las dns que quiero en la white listla de cla
ipset --create whitelist hash:net
ipset add whitelist 1.1.1.3/32
ipset add whitelist 8.8.8.8/32

# en mi blacklist he quitado estas 
ipset --create badlist hash:net
ipset add badlist 3.2.1.0/24
ipset add badlist 69.90.69.123/32
ipset add badlist 90.90.123.80/32
ipset add badlist 35.43.69.0/24

#para guardar ipset es este comando cosa importante (no me funcionaba el ipset hasta que en clase dijiste que teniamos que guardarlas )
ipset save > /etc/iptables/ipsets
