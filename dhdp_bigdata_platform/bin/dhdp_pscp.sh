#!/bin/bash

function usage(){
	echo '[-] Usage: dhdp_pscp.sh [arg] [host_str] [source_dir] [target_dir] '
	echo 'arg_dir is -r :synchronization directory / -H : Single node synchronization'
}

##需上传至目录

arg=$1
host_str=$2
source_dir=$3
target_dir=$4

log_dir=/var/log/pssh/pscp

if [ -z $1 ];then
	usage
	exit 1
fi

if [[ $arg == "-r" ]];then
	echo "pscp Dir : $host_str $source_dir"
	pscp $arg -e $log_dir -p 8 -h /home/hadoop/dhdp/conf/conf_ops/hosts $host_str $source_dir
	
elif [[ $arg == "-H" ]];then
	echo "pscp -H : $source_dir $target_dir"
	pscp -e $log_dir -p 8 -H $host_str $source_dir $target_dir
else 
	echo "pscp : $source_dir $target_dir"
	pscp -e $log_dir -p 8 -h /home/hadoop/dhdp/conf/conf_ops/hosts $arg $host_str
	
fi