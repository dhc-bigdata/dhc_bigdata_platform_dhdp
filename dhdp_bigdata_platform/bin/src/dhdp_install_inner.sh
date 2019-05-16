#!/bin/bash

function usage(){
	echo -e '[-] Usage: dhdp_install_inner.sh [mode]\nmode should be in (install)'
}

echo 'execute dhdp_install_inner.sh begin ...'

if [ "x$USER" != "xroot" ];then
	echo "[-] Install using the root user..."
	exit 1
fi

if [ "x$1" != "xinstall" ];then
	usage
	exit 1
fi
#开始时间
starttime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);

dhdp_home=/home/hadoop/dhdp
#获取集群主机名
hosts=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`


#为第一台主机安装工具使其拥有expect能力和pssh能力
function first_host_install_tools(){
	echo "------->first_host_install_tools  start<-------"
	#挂载镜像
	. $dhdp_home/bin/src/dhdp_utils.sh && mount_os
	ret=$?
	if [ $ret != 0 ];then
		exit $ret
	fi
	
	#安装工具
	. $dhdp_home/bin/src/dhdp_each_host_install_tools.sh && install_tools
	ret=$?
	if [ $ret != 0 ];then
		exit $ret
	fi
	echo "------->first_host_install_tools  end<-------"
}

first_host_install_tools

#复制xml文件到conf
/usr/bin/expect <<-EOF
        #set timeout 30
        spawn cp /root/dhdp/dhdp_hosts.xml /home/hadoop/dhdp/conf/conf_ops
        expect {
                "cp: overwrite*’?" {send "y" \n}
        }
        #expect eof
EOF

ret=$?
if [ $ret != 0 ];then
	exit $ret
fi

#初始化主机名
. $dhdp_home/bin/src/dhdp_utils.sh && init_hostname
ret=$?
if [ $ret != 0 ];then
	exit $ret
fi

#初始化主机映射hosts
. $dhdp_home/bin/src/dhdp_utils.sh && init_hosts
ret=$?
if [ $ret != 0 ];then
	exit $ret
fi

#对第一台主机root用户生成公私钥并对其他主机进行免密操作
ret=$?
if [ $ret != 0 ];then
	exit $ret
fi

#配置防火墙以及关闭seLinux
for host in $hosts;do
	dhdp_pssh.sh -H $host "bash $dhdp_home/bin/src/dhdp_config_each_firewalld.sh"
done
ret=$?
if [ $ret != 0 ];then
	exit $ret
fi

#配置时间同步
hostname=`hostname`
if [ $hostname == "hadoop01" ];then
	. $dhdp_home/bin/src/dhdp_utils.sh && sync_time
fi
ret=$?
if [ $ret != 0 ];then
	exit $ret
fi

#分发dhdp软件包
function share_dhdp(){
	#读取除过第一台主机的其他主机名
	delete_first_hosts=`python $dhdp_home/bin/src/dhdp_xml_delete_hostname.py`
	for host in $delete_first_hosts;do
		echo "------>Synchronize dhdp start<------"
		dhdp_pssh.sh -H $host "mkdir /home/hadoop"
		echo pscp -r -H $host $dhdp_home /home/hadoop
		pscp -r -e /var/log/pssh/pscp -H $host $dhdp_home/ /home/hadoop/
		dhdp_pssh.sh -H $host "chown -R hadoop:hadoop /home/hadoop/dhdp"
		echo "------>Synchronize dhdp start<------"

		echo "------>Synchronize iso start<------"
		dhdp_pssh.sh -H $host "mkdir /root/dhdp"
		dhdp_pscp.sh -H $host /root/dhdp/CentOS-7-x86_64-DVD-1810.iso /root/dhdp/
		echo "------>Synchronize iso start<------"
	done

}

share_dhdp

#配置用户组
dhdp_pssh.sh -h ". $dhdp_home/bin/src/dhdp_each_host_config_user.sh"

#配置hadoop用户的免密
su - hadoop <<-EOF

EOF

#初始化集群本地资源
dhdp_pssh.sh -h "bash $dhdp_home/bin/src/dhdp_init_local_rescource.sh"
ret=$?
if [ $ret != 0 ];then
	exit $ret
fi

#初始化集群环境变量
for host in $hosts;do
	$dhdp_home/bin/dhdp_pssh.sh -H $host "rm -rf /home/hadoop/.bashrc"
	$dhdp_home/bin/dhdp_pssh.sh -H $host "cp $dhdp_home/conf/conf_ops/dhdp_env /home/hadoop/.bashrc"
	$dhdp_home/bin/dhdp_pssh.sh -H $host "cp $dhdp_home/conf/conf_ops/dhdp_env /root/.bashrc"
	$dhdp_home/bin/dhdp_pssh.sh -H $host "source /home/hadoop/.bashrc"
	$dhdp_home/bin/dhdp_pssh.sh -H $host "source /root/.bashrc"
done

#安装除第一台主机外其他主机
function except_first_host_install_tools(){
	#读取除过第一台主机的其他主机名
	delete_first_hosts=`python $dhdp_home/bin/src/dhdp_xml_delete_hostname.py`
	for host in $delete_first_hosts;do
		echo "------>except_first_host_install_tools start<------"	
		dhdp_pssh.sh -H $host ". $dhdp_home/bin/src/dhdp_utils.sh && mount_os"
		dhdp_pssh.sh -H $host ". $dhdp_home/bin/src/dhdp_each_host_install_tools.sh && install_tools"
		dhdp_pssh.sh -H $host ". $dhdp_home/bin/src/dhdp_each_host_install_tools.sh && install_database"
		echo "------>except_first_host_install_tools end<------"
	done
}

#初始化集群
function init_Cluster(){
	echo "------->init_Cluster  start<-------"
	bash $dhdp_home/bin/src/dhdp_each_host_init.sh
	echo "------->init_Cluster  stop<-------"
}



#结束时间
endtime=`date +'%Y-%m-%d %H:%M:%S'`
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"
echo 'execute dhdp_install_inner.sh end ...'