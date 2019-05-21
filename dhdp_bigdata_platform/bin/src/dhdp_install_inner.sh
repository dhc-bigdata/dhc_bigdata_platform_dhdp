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
bash $dhdp_home/bin/src/dhdp_each_host_ssh_user.sh root
ret=$?
if [ $ret != 0 ];then
	exit $ret
fi

#初始化第一台主机hadoop密码
. $dhdp_home/bin/src/dhdp_each_host_config_user.sh && config_user

#删除垃圾文件
#delete_first_hosts=`python $dhdp_home/bin/src/dhdp_xml_delete_hostname.py`
#for host in $delete_first_hosts;do
#	bash $dhdp_home/bin/dhdp_pssh.sh -H $host "rm -rf /home/hadoop"
#done

#配置防火墙以及关闭seLinux
for host in $hosts;do
	bash $dhdp_home/bin/dhdp_pssh.sh -H $host "systemctl stop firewalld"
	bash $dhdp_home/bin/dhdp_pssh.sh -H $host "systemctl disable firewalld"
	bash $dhdp_home/bin/dhdp_pssh.sh -H $host "sed -i 's!SELINUX=enforcing!SELINUX=disabled!g' /etc/selinux/config"
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

#启动时间同步定时任务
delete_first_hosts=`python $dhdp_home/bin/src/dhdp_xml_delete_hostname.py`
for host in $delete_first_hosts;do
	pssh -H $host "echo '0-59/1 * * * * /usr/sbin/ntpdate hadoop01' >> /etc/crontab"
done
ret=$?
if [ $ret != 0 ];then
	exit $ret
fi

#分发dhdp软件包
function share_dhdp(){
	#读取除过第一台主机的其他主机名
	delete_first_hosts=`python $dhdp_home/bin/src/dhdp_xml_delete_hostname.py`
	for host in $delete_first_hosts;do
		echo "------>Synchronize dhdp to $host start<------"
		bash $dhdp_home/bin/dhdp_pssh.sh -H $host "mkdir /home/hadoop"
		sleep 5
		echo pscp -r -H $host $dhdp_home /home/hadoop
		pscp -r -e /var/log/pssh/pscp -H $host $dhdp_home /home/hadoop/
		
		sleep 5
		echo "------>Synchronize dhdp to $host end<------"

		echo "------>Synchronize iso to $host start<------"
		#bash $dhdp_home/bin/dhdp_pssh.sh -H $host "rm -rf /root/dhdp"
		bash $dhdp_home/bin/dhdp_pssh.sh -H $host "mkdir /root/dhdp"
		bash $dhdp_home/bin/dhdp_pscp.sh -H $host /root/dhdp/CentOS-7-x86_64-DVD-1810.iso /root/dhdp/
		sleep 5
		echo "------>Synchronize iso to $host end<------"
	done

}

share_dhdp

#配置用户组
delete_first_hosts=`python $dhdp_home/bin/src/dhdp_xml_delete_hostname.py`
for host in $delete_first_hosts;do
	echo "------>config user to $host start<------"
	bash $dhdp_home/bin/dhdp_pssh.sh -H $host "useradd hadoop"
	ssh $host 'yum install -y expect'
	bash $dhdp_home/bin/dhdp_pssh.sh -H $host ". $dhdp_home/bin/src/dhdp_each_host_config_user.sh && config_user"
	bash $dhdp_home/bin/dhdp_pssh.sh -H $host "usermod root -G hadoop"
	bash $dhdp_home/bin/dhdp_pssh.sh -H $host "usermod hadoop -G root"
	bash $dhdp_home/bin/dhdp_pssh.sh -H $host "chmod -R 750 /home/hadoop"
	#ssh $host '\cp /etc/skel/.* /home/hadoop/'
	echo "------>config user to $host end<------"
done


#配置hadoop用户的免密
su - hadoop <<-EOF
	bash $dhdp_home/bin/src/dhdp_each_host_ssh_user.sh hadoop
EOF

#初始化集群本地资源
bash $dhdp_home/bin/dhdp_pssh.sh -h "bash $dhdp_home/bin/src/dhdp_init_local_rescource.sh"
ret=$?
if [ $ret != 0 ];then
	exit $ret
fi

#初始化集群环境变量
for host in $hosts;do
	$dhdp_home/bin/dhdp_pssh.sh -H $host "rm -rf /home/hadoop/.bashrc"
	$dhdp_home/bin/dhdp_pssh.sh -H $host "rm -rf /.bashrc"
	$dhdp_home/bin/dhdp_pssh.sh -H $host "\cp $dhdp_home/conf/conf_ops/dhdp_env /home/hadoop/.bashrc"
	$dhdp_home/bin/dhdp_pssh.sh -H $host "\cp $dhdp_home/conf/conf_ops/dhdp_root_env /root/.bashrc"
	$dhdp_home/bin/dhdp_pssh.sh -H $host "source /home/hadoop/.bashrc"
	$dhdp_home/bin/dhdp_pssh.sh -H $host "source /root/.bashrc"
done

#安装除第一台主机外其他主机
function except_first_host_install_tools(){
	echo "------>except_first_host_install_tools start<------"	
	#读取除过第一台主机的其他主机名
	delete_first_hosts=`python $dhdp_home/bin/src/dhdp_xml_delete_hostname.py`
	for host in $delete_first_hosts;do
		
		ssh $host '. $dhdp_home/bin/src/dhdp_utils.sh && mount_os'
		ssh $host '. $dhdp_home/bin/src/dhdp_each_host_install_tools.sh && install_tools'
		ssh $host 'bash $dhdp_home/bin/src/dhdp_install_mysql.sh install 5.7.22'
	done
	echo "------>except_first_host_install_tools end<------"
}

except_first_host_install_tools
#初始化集群

function init_Cluster(){
	echo "------->init_Cluster  start<-------"
	bash $dhdp_home/bin/dhdp_pssh.sh -h "bash $dhdp_home/bin/src/dhdp_init_local_rescource.sh"
	bash $dhdp_home/bin/dhdp_pssh.sh -h "chown -R hadoop:hadoop /home/hadoop"
	
	hostname=`cat /etc/hostname`
	if [ $hostname == "hadoop01" ];then
		su - hadoop <<-EOF
		bash $dhdp_home/bin/src/dhdp_init_hadoop_resource.sh format
		bash $dhdp_home/bin/src/dhdp_init_hadoop_resource.sh copy_resource
		bash $dhdp_home/bin/src/dhdp_init_hadoop_resource.sh init_hdfs
		bash $dhdp_home/bin/src/dhdp_init_hadoop_resource.sh special_config
		EOF
	fi
	
	
	echo "------->init_Cluster  stop<-------"
}
init_Cluster


#结束时间
endtime=`date +'%Y-%m-%d %H:%M:%S'`
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"
echo 'execute dhdp_install_inner.sh end ...'
