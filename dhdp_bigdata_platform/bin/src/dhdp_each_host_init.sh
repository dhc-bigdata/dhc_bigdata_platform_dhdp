#!/bin/bash
#初始化hadoop用户、修改主机映射、配置hadoop及root用户免密、时间同步服务器、关闭防火墙、关闭selinux

dhdp_bin_dir=/home/hadoop/dhdp/bin/
if [ "x$USER" != "xroot" ];then
	echo "[-] Install using the root user..."
	exit 1
fi

#配置集群内各主机的hostname
bash $dhdp_home/bin/src/dhdp_init_hostname.sh

#配置防火墙以及关闭seLinux
hosts=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
for host in $hosts;do
	dhdp_pssh.sh -H $host "bash $dhdp_home/bin/src/dhdp_config_each_firewalld.sh"
done

#初始化用户
for host in $hosts;do
	dhdp_pssh.sh -H $host "bash $dhdp_home/bin/src/dhdp_each_host_config_user.sh"
done
bash $dhdp_home/bin/src/dhdp_each_host_config_user.sh

#生成公私钥以及分发公私钥
hosts=`python $dhdp_bin_dir/src/dhdp_hadoop_xml_utils.py hostname`

for host in $hosts;do
	/usr/bin/expect <<EOF
		set timeout 300
		spawn ssh -o stricthostkeychecking=no root@$host
		expect {
				"(yes/no)" {send "yes\r"; exp_continue}
				"password:" {send "${root_password}\n; exp_continue"}
		}
		expect "]#"  {send ". dhdp_utils.sh && ssh_key_gen \n"}
		expect "]#"  {send ". dhdp_utils.sh && ssh_copy_id_all \n"}
		expect "]#"  {send "exit\n"}
		#expect eof
EOF

done

#初始化集群本地资源
dhdp_pssh.sh -h "bash $dhdp_bin_dir/src/dhdp_init_local_rescource.sh"

#初始化hdoop资源

bash $dhdp_bin_dir/src/dhdp_init_hadoop_resource.sh

