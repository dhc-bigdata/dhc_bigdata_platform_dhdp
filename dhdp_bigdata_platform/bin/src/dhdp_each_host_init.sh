#!/bin/bash
#初始化hadoop用户、修改主机映射、配置hadoop及root用户免密、时间同步服务器、关闭防火墙、关闭selinux

dhdp_bin_dir=/home/hadoop/dhdp/bin/
if [ "x$USER" != "xroot" ];then
	echo "[-] Install using the root user..."
	exit 1
fi

#配置防火墙
cd $dhdp_bin_dir && dhdp_config_each_firewalld.sh

#配置用户
cd $dhdp_bin_dir && dhdp_each_host_config_user.sh
