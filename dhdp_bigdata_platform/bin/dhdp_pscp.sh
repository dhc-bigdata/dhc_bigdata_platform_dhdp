#!/bin/bash

function usage(){
	echo '[-] Usage: dhdp_pscp.sh [arg_dir] [source_dir] [target_dir]'
	echo 'arg_dir is -r :synchronization directory'
}

##需上传至目录
source_dir=$1
target_dir=$2
arg_dir=$3
log_dir=/var/log/pssh/pscp

if [ -z $1 ];then
	usage
	exit 1
fi

if [[ $arg_dir != "-r" ]];then
	echo "pscp : $source_dir $target_dir"
	pscp -e $log_dir -p 8 -h /home/hadoop/dhdp/conf/conf_ops/hosts $source_dir $target_dir
else
	echo "pscp Dir : $source_dir $target_dir"
	pscp $arg_dir -e $log_dir -p 8 -h /home/hadoop/dhdp/conf/conf_ops/hosts $source_dir $target_dir
fi
	