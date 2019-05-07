#!/bin/bash
dhdp_dir=/home/hadoop/dhdp/bin/

echo 'execute dhdp_install_one_key_launch.sh begin ...'

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

mkdir -p /home/hadoop

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
fi

echo "execute dhdp_install_one_key_inner.sh ..."
cd /home/hadoop/dhdp/bin/src && bash dhdp_install_inner.sh $mode

echo 'execute dhdp_install_one_key_launch.sh end ...'

#hosts=`cat /home/hadoop/dhdp/conf/conf_ops/hosts`
#
#for host in $hosts;do
#    /usr/bin/expect <<EOF
#	set timeout 120
#	spawn ssh -o stricthostkeychecking=no root@$host
#	expect "]#"  {send "cd $dhdp_dir && bash dhdp_each_host_init.sh \n"}
#	expect "]#"  {send "cd $dhdp_dir && bash dhdp_each_host_init_resource.sh \n"}
#	expect "]#"  {send "cd $dhdp_dir && bash dhdp_each_host_install_tools.sh \n"}
#	expect "]#"  {send "exit\n"}
#	#expect eof
#EOF
#done

