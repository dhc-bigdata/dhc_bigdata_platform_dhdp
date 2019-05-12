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
hosts=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.sh hostname`
#安装pssh以简化此后操作
bash $dhdp_home/bin/src/dhdp_install_pssh.sh

#循环使用pssh在每台机器执行安装
for host in $hosts;do
    pssh -h
done


#结束时间
endtime=`date +'%Y-%m-%d %H:%M:%S'`
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"