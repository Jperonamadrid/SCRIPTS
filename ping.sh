#!/bin/bash

for i in {2..255}
	do 
		echo $(ping -c 1 172.16.11.$i) >> ips.txt
		grep -e "ttl=" ips.txt > ipsBuenas.txt
		
	done
