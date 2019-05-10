#!/bin/bash
hostnames="hadoop01 hadoop02 hadoop03"#hostname
ips="192.168.120.115  192.168.120.116" #主机
function init_hostname(){
	echo "$1"  >> /etc/hostname
	for host in $hostnames and ip in $ips
	do
		echo "$host  $ip"  >> /etc/hosts
	done
}
init_hostname $1
