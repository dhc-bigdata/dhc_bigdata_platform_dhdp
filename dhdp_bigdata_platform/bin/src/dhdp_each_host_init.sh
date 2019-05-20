#!/bin/bash
#初始化hadoop用户、修改主机映射、配置hadoop及root用户免密、时间同步服务器、关闭防火墙、关闭selinux

dhdp_home=/home/hadoop/dhdp/
hosts=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
if [ "x$USER" != "xroot" ];then
	echo "[-] Install using the root user..."
	exit 1
fi

#初始化hdoop资源
su - hadoop <<-EOF
	bash $dhdp_home/bin/src/dhdp_init_hadoop_resource.sh
EOF


