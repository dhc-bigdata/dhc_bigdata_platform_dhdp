#!/bin/bash
#####################################################################
#					CentOS7 初始化									#
#各主机安装基本软件：openssh-server vim gcc gcc-c++ glibc-headers 	#
#bzip2-devel lzo-devel curl wget openssh-clients zlib-devel expect	#
#autoconf automake cmake libtool openssl-devel fuse-devel dos2unix 	#
#snappy-devel telnet unzip zip net-tools.x86_64 firewalld systemd、 #
#配置防火墙永久关闭、关闭SELinux）									#
#####################################################################
dhdp_bin=/home/hadoop/dhdp/bin #shell脚本存放目录
dhdp_data=/home/hadoop/dhdp/data #数据目录
dhdp_conf=/home/hadoop/dhdp/conf #最新的配置文件存放目录
dhdp_core=/home/hadoop/dhdp/core #大数据组件安装目录
dhdp_package=/home/hadoop/dhdp/package #安装包存放目录
dhdp_log=/home/hadoop/dhdp/logs #集群存放日志
dhdp_share=/home/hadoop/dhdp/share #集群文档存放目录

#如果文件夹不存在，则创建
[ ! -d dhdp_log ] && mkdir -pdhdp_log] && mkdir -pdhdp_log
#检查执行状态，将状态写入日志文件
function check(){
	echo '----------------------------------------------------------------------------'
	echo '[+] check status then wirite to log begin ...'
	if [ $? != 0 ]
	then
	echo "××××-Operate Failed!!!−×××>>Failed!!!">>log_file
	else
	echo "√√√√-Operate Success!!!−√√√>>Success!!!">>log_file
	fi
	echo '[-] check status then wirite to log end ...'
	}
#安装各种依赖库
function install_dependence_library(){
	echo '----------------------------------------------------------------------------'
	echo '[+] execute install_dependence_library begin ...'
	if [ "x$USER" != "xroot" ];then
		return
	fi
	yum install -y ncurses-devel gcc*  openssh-clients openssh-server
	yum install -y zlib-devel autoconf* automake libtool* cmake openssl-devel fuse-devel
	yum install -y unzip zip vim* dos2unix expect telnet*
	yum install -y net-tools firewalld* systemd*
	yum install -y lzo-devel snappy-devel
	check dependence_library
	echo '[-] execute install_dependence_library end ...'
}
#关闭防火墙，禁止开机启动
#firewall
function CloseFirewall(){
	echo '----------------------------------------------------------------------------'
	echo '[+] execute CloseFirwall begin ...'
	if [ "x$USER" != "xroot" ];then
		echo "[-] You must use the root user to execute close_firewalld"
		return
	fi
    systemctl stop firewalld  #停止firewall
    systemctl disable firewalld  #禁止firewall开机启动
    systemctl status firewalld #查看firewall状态
	check CloseFirewall
	echo '[-] execute CloseFirwall end ...'
}

#关闭selinux，修改配置文件后，同时设置临时生效
#selinux  disable the selinux
function CloseSelinux(){
	echo '----------------------------------------------------------------------------'
	echo '[+] execute CloseSelinux begin ...'
	status=`grep SELINUX= /etc/selinux/config | tail -1 | awk -F '='  '{print $2}'`
	if [ $status != disabled ]
	then
	sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
	status=`grep SELINUX= /etc/selinux/config | tail -1 | awk -F '='  '{print $2}'`
		if [ $status == disabled ]
		then
		echo "√√√-Modify selinux config success-√√√-" >>$log_file
		else
		echo "×××-Modify selinux config Failed!!!-×××" >>$log_file
		fi
	else
	echo "Selinx config already Modified">>$log_file
	fi
	setenforce 0  #关闭selinux防火墙
	check setenfore
	echo '[-] execute CloseSelinux end  ...'
}
#主函数
#main
function main(){
	echo "Deploy Linux *****`date +"%Y-%m-%d_%H-%M-%S"`*****"
	install_dependence_library
	CloseFirewall
	CloseSelinux
}
main