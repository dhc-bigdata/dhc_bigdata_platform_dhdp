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

#分发dhdp软件包

#复制xml文件到conf
/usr/bin/expect <<-EOF
        #set timeout 30
        spawn cp /root/dhdp/dhdp_hosts.xml /home/hadoop/dhdp/conf/conf_ops
        expect {
                "cp: overwrite*’?" {send "y" \n}
        }
        #expect eof
EOF

echo ". /home/hadoop/dhdp/bin/src/dhdp_utils.sh" >> /root/.bashrc
source /root/.bashrc

#给第一台主机安装软件

function first_host_install(){
	#挂载镜像
	mount_os
	
	#安装工具
	. $dhdp_home/bin/src/dhdp_each_host_install_tools.sh && install_tools
	
}

#初始化集群
bash $dhdp_home/bin/src/dhdp_each_host_init.sh


#循环使用pssh在每台机器执行安装
for host in $hosts;do
    echo "主机名+"$host
done


#结束时间
endtime=`date +'%Y-%m-%d %H:%M:%S'`
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"
echo 'execute dhdp_install_inner.sh end ...'