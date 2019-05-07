#!/bin/bash

#启动集群中所有节点的各组件进程,任意节点上可执行
function start_or_stop_all_component(){
	echo "[+] The start_or_stop_all_component function begin..."
	if [ "x$USER" != "xhadoop" ];then
		echo "[-] The user that this method executes must be hadoop ..."
		return
	fi

	if [ "x$HOSTNAME" != "xhadoop01" ];then
		echo "[-] Please perform this operation on the hadoop01 node ..."
		return
	fi

	if [ "x$1" != "xstop" ] && [ "x$1" != "xstart" ];then
		echo "[-] The parameter is incorrect. The parameter can only be start or stop ..."
		return
	fi
	#获取集群中各主机IP
	IPs=`sed -n 3,5p /etc/hosts | awk '{print $1}'`
	#将IP字符串转化为数组
	IPs_array=($IPs)
	#启动集群所有节点的zookeeper进程
	pssh -H "$IPs" -t 10000 -l hadoop -i "zkServer.sh $1"
	#在hadoop01节点启动hdfs
	echo "=======================||  starting  HDFS  ||======================="
	$1-dfs.sh
	#在hadoop01节点启动yarn
	echo "=======================||  starting  YARN  ||===================="
	$1-yarn.sh
	#在hadoop01节点启动hbase
	echo "=======================||  starting  HBASE  ||======================="
	if [ "x$1" == "xstart" ];then
		 $1-hbase.sh
	else
		#直接kill掉由于使用stop命令hbase未停止的进程
		pssh -H "$IPs" -t 10000 -l hadoop -i "bash /home/hadoop/bin/dhdp_start_or_stop_hadoop.sh kill hbase"
	fi

	#在hadoop01节点启动spark
	echo "=======================||  starting SPARK  ||======================="
	spark-$1-all.sh

	#启动集群中所有节点的kafka进程
	echo "=======================||  starting  KAFKA  ||======================="
	pssh -H "$IPs" -t 10000 -l hadoop -i "nohup kafka-server-$1.sh /home/hadoop/core/kafka_2.11-1.1.0/config/server.properties 1>/home/hadoop/logs/kafka/kafka_std.log 2>/home/hadoop/logs/kafka/kafka_err.log  &"

	#在hadoop02节点启动ResourceManager
	echo "=======================|| starting the hadoop02 ResourceManager  ||======================="
	pssh -H ${IPs_array[1]} -t 10000 -l hadoop -i "yarn-daemon.sh $1 resourcemanager"
	#在hadoop02节点启动Master
	echo "=======================||  starting the hadoop02 Master  ||======================="
	pssh -H ${IPs_array[1]} -t 10000 -l hadoop -i "$1-master.sh"
	#在hadoop03节点启动MySql
	echo "=======================||  starting the hadoop03 MySql  ||======================="
	pssh -H ${IPs_array[2]} -t 10000 -l hadoop -i "/etc/init.d/mysqld $1"

	#显示所有节点的服务进程
	pssh -H "$IPs" -t 10000 -l hadoop -i "jps"

	echo "[-] The start_or_stop_all_component function end..."
}

#按照进程名kill掉其进程
function kill_all_progress_by_Cname(){
	echo "[+] The kill_all_progress_by_Cname function start ..."

	#传入的需要kill的组件名字
	cname=$1

	if [ "x$USER" != "xhadoop" ];then
		echo "[-] The user that this method executes must be hadoop ..."
		return
	fi

	if [ -z "$1" ];then
		echo '[-] Usage: kill_all_progress_by_Cname [name]'
		echo 'explain: [name] should be progressName or componentName,for example:dfs|yarn|zookeeper|hbase|namenode|mysql|hmaster......'
		return
	fi

	dfs_progress_array=("NameNode" "DataNode" "JournalNode" "DFSZKFailoverController")
	yarn_progress_array=("ResourceManager" "NodeManager")
	zookeeper_progress_array=("QuorumPeerMain")
	hbase_progress_array=("HMaster" "HRegionServer")
	current_array=()

	if [ "x$cname" == "xdfs" ];then
		current_array=${dfs_progress_array[@]}
	elif [ "x$cname" == "xyarn" ];then
		current_array=${yarn_progress_array[@]}
	elif [ "x$cname" == "xzookeeper" ];then
		current_array=${zookeeper_progress_array[@]}
	elif [ "x$cname" == "xhbase" ];then
		current_array=${hbase_progress_array[@]}
	else
		#mysql不是java进程 需要进行单独处理
		if [ "x$cname" == "xmysql" ];then
			pid=`ps ax | grep port=3306 | grep -v grep | awk '{print $1}'`
			if [ -n "$pid" ];then
				#关闭mysqld_safe
				pid_mysqld_safe=`ps ax | grep mysqld_safe | grep -v grep | awk '{print $1}'`
				if [ -n "$pid_mysqld_safe" ];then
					kill -9 $pid_mysqld_safe
					echo "[+] The mysqld_safe progress is killed successful ..."
				fi
				#关闭mysqld
				kill -9 $pid
				echo "[+] The mysql progress is killed successful ..."
			fi
		else
		    #如果传入的不是某个组件名而是具体某个进程名,则直接kill掉
			cid=`jps | grep -i $cname | awk '{print $1}'`
			if [ -n "$cid" ];then
				kill -9 $cid
				echo "[+] The $cname progress is killed successful ..."
			fi
		fi
	fi
	#如果传入是某个组件名,遍历其组件数组,将该组件包含的进程全部kill掉
	for progress in $current_array;
	do
		cid=`jps | grep -i $progress | awk '{print $1}'`
		if [ -n "$cid" ];then
			kill -9 $cid
			echo "[+] The $progress progress is killed successful ..."
		fi
	done
	echo "[+] The kill_all_progress_by_Cname function end..."
}

#主方法
function main(){
	if [ "x$1" == "xstart" ] || [ "x$1" == "xstop" ];then
		start_or_stop_all_component $1
		elif [ "x$1" == "xkill" ];then
		kill_all_progress_by_Cname $2
		else
			echo '[-] Usage: dhdp_start_or_stop_hadoop.sh [mode]'
			echo '[-] explain:[mode] should be in (start | stop | kill )'
		return
	fi
}
main $1 $2