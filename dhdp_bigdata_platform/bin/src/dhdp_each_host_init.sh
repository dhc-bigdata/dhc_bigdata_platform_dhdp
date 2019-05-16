#!/bin/bash
#初始化hadoop用户、修改主机映射、配置hadoop及root用户免密、时间同步服务器、关闭防火墙、关闭selinux

dhdp_home=/home/hadoop/dhdp/
hosts=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
if [ "x$USER" != "xroot" ];then
	echo "[-] Install using the root user..."
	exit 1
fi

#配置防火墙以及关闭seLinux
for host in $hosts;do
	dhdp_pssh.sh -H $host "bash $dhdp_home/bin/src/dhdp_config_each_firewalld.sh"
done
#配置时间同步
hostname=`hostname`
if [ $hostname == "hadoop01" ];then
	. $dhdp_home/bin/src/dhdp_utils.sh && sync_time
fi

#初始化集群本地资源
dhdp_pssh.sh -h "bash $dhdp_home/bin/src/dhdp_init_local_rescource.sh"

#初始化hdoop资源

bash $dhdp_home/bin/src/dhdp_init_hadoop_resource.sh

