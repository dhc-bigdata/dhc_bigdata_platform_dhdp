#!/bin/bash


#使用root用户执行
echo 'execute dhdp_install.sh begin ...'

function usage(){
	echo '[-] Usage: dhdp_install.sh [version] [mode]'
	echo 'mode should be in (install)'
	echo '-u means that the pressure has been decompressed and no further decompression is needed to save time '
}


if [ "x$USER" != "xroot" ];then
	echo "[-] Install using the root user."
	exit 1
fi

if [ -z $1 ];then
	usage
	exit 1
fi

if [ "x$2" != "xinstall" ];then
	usage
	exit 1
fi

version=$1

echo "uncompress dhdp_install_launch.sh ..."
cd /root/dhdp && tar -zxvf dhdp-$version.tar.gz
cp dhdp-$version/bin/src/dhdp_install_launch.sh .

echo "bash dhdp_install_launch.sh. show log in /root/logs/install_log_all.log ..."
mkdir -p /root/logs && rm -rf /root/logs/*
bash dhdp_install_launch.sh $1 $2 > /root/logs/install_log_all.log 2>&1

#删除临时文件
rm -rf /root/dhdp/dhdp-$version /root/dhdp/dhdp_install_launch.sh

echo 'execute dhdp_install.sh end ...'

