#!/bin/bash
dhdp_dir=/home/hadoop/dhdp/bin/

echo 'execute dhdp_install_one_key_launch.sh begin ...'
function usage(){
	echo '[-] Usage: dhdp_install_lanuch.sh [version] [mode] [-u]'
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

mode=$2
echo mode: $mode

useradd hadoop
usermod root -G hadoop
usermod hadoop -G root
chmod -R 750 /home/hadoop

is_uncompressed=$3
echo "is_uncompressed : $is_uncompressed"

if [[ $is_uncompressed != "-u" ]];then		#-u表示已解压过，不需要再进行解压，节约时间
	file_name_prefix_tar=dhdp-$1
	echo "uncompress $file_name_prefix_tar.tar.gz ..."
	cd /root/dhdp && rm -rf $file_name_prefix_tar && tar -zxf $file_name_prefix_tar.tar.gz
	
	if [ $? == 2 ];then
		echo ""
		echo "please check the dhdp version."
		exit 2
	fi

	#用新文件夹替换原文件夹
	echo "mv $file_name_prefix_tar to /home/hadoop/dhdp ..."
	rm -rf /home/hadoop/dhdp && mv /root/dhdp/$file_name_prefix_tar /home/hadoop/dhdp
	#处理bin、conf下所有文件中换行符格式
	. /home/hadoop/dhdp/bin/src/dhdp_utils.sh Doc2Unix /home/hadoop/bin/* /home/hadoop/conf/*
fi

echo "execute dhdp_install_inner.sh ..."
cd /home/hadoop/dhdp/bin/src && bash dhdp_install_inner.sh $mode

echo 'execute dhdp_install_one_key_launch.sh end ...'


