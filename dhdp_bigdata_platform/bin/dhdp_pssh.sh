#!/bin/bash


arg=$1
host_str=$2
v_order=$3

log_dir=/var/log/pssh/pssh


if [[ $arg == "-H" ]];then
	echo "pssh -H : $v_order"
	pssh -e $log_dir $arg $host_str $v_order
else 
	echo "pssh -h : $host_str"
	pssh -e $log_dir $arg /home/hadoop/dhdp/conf/conf_ops/hosts $host_str	
	
fi