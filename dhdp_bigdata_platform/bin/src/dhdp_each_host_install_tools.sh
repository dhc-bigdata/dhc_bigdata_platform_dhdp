#!/bin/bash
#安装基础软件、以及工具  比如pssh、java、mysql

dhdp_bin_dir=/home/hadoop/dhdp/bin/src/
hostname=`hostname`

function install_tools(){
	
	#挂载镜像
	cd $dhdp_bin_dir
	
	mount_os
	
	#安装基础软件
	yum install -y ncurses-devel gcc*  openssh-clients openssh-server
	yum install -y zlib-devel autoconf* automake libtool* cmake openssl-devel fuse-devel
	yum install -y unzip zip vim* dos2unix expect telnet*
	yum install -y net-tools firewalld* systemd*
	yum install -y lzo-devel snappy-devel ntp ntpdate
	check dependence_library

	#安装pssh
	bash $dhdp_bin_dir/dhdp_install_pssh.sh
	ret=$?
	if [ $ret != 0 ];then
		exit $ret
	fi

	#安装pssh
	bash $dhdp_bin_dir/dhdp_install_pssh.sh
	ret=$?
	if [ $ret != 0 ];then
		exit $ret
	fi



}

function install_database(){
	#只在最后一台机器安装
	if [ $hostname == "hadoop03" ];then
		cd $dhdp_bin_dir && bash dhdp_install_mysql.sh install 5.7.22
	fi
}







