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
	. $dhdp_bin_dir/dhdp_utils.sh && mount_os
	
	#安装工具
	. $dhdp_home/bin/src/dhdp_each_host_install_tools.sh && install_tools
	echo "------->first_host_install_tools  end<-------"
	
}

#初始化集群
function init_Cluster(){
	echo "------->init_Cluster  start<-------"
	bash $dhdp_home/bin/src/dhdp_each_host_init.sh
	echo "------->init_Cluster  stop<-------"
}




#安装除第一台主机外其他主机
function except_first_host_install_tools(){
	#读取除过第一台主机的其他主机名
	delete_first_hosts=`python dhdp_xml_delete_hostname.py`
	for host in $delete_first_hosts;do
		echo "------>except_first_host_install_tools start<------"	
		dhdp_pssh.sh -H $host ". $dhdp_bin_dir/dhdp_utils.sh && mount_os"
		dhdp_pssh.sh -H $host ". $dhdp_home/bin/src/dhdp_each_host_install_tools.sh && install_tools"
		dhdp_pssh.sh -H $host ". $dhdp_home/bin/src/dhdp_each_host_install_tools.sh && install_database"
		echo "------>except_first_host_install_tools end<------"
	done
}

#分发dhdp软件包
function share_dhdp(){
	#读取除过第一台主机的其他主机名
	delete_first_hosts=`python dhdp_xml_delete_hostname.py`
	for host in $delete_first_hosts;do
		echo "------>Synchronize dhdp start<------"
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
#配置集群免密
function process_cluster_ssh(){
    #生成公私钥以及分发公私钥(待处理)
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
process_cluster_ssh
share_dhdp
except_first_host_install_tools
init_Cluster

#结束时间
endtime=`date +'%Y-%m-%d %H:%M:%S'`
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"
echo 'execute dhdp_install_inner.sh end ...'