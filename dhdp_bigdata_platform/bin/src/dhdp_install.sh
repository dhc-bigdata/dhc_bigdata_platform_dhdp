#!/bin/bash

function usage(){
	echo '[-] Usage: dhdp_install.sh [version] [mode] [-u]'
	echo 'mode should be in (install)'
	echo '-u means that the pressure has been decompressed and no further decompression is needed to save time '
}

#使用root用户执行
echo 'execute dhdp_install.sh begin ...'
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
#安装dos2unix以便后续处理安装脚本格式问题
yum install -y dos2unix

cd /root/dhdp && tar -zxf dhdp-$version.tar.gz dhdp-$version/bin/src/dhdp_install_launch.sh dhdp-$version/bin/src/dhdp_utils.sh

#处理文件换行符格式
dos2unix dhdp-$version/bin/src/dhdp_utils.sh
dos2unix dhdp-$version/bin/src/dhdp_install_launch.sh

echo "bash dhdp_install_launch.sh. show log in /root/logs/install_log_all.log ..."
mkdir -p /root/logs
bash /root/dhdp/dhdp-$version/bin/src/dhdp_install_launch.sh $1 $2 > /root/logs/install_log_all.log 2>&1
#删除临时文件
rm -rf /root/dhdp/dhdp-$version

echo 'execute dhdp_install.sh end ...'

