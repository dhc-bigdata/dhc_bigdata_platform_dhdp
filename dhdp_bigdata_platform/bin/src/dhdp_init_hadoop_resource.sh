#!/bin/bash
#初始化平台数据目录、日志目录 配置目录权限用户组

dhdp_bin_dir=/home/hadoop/dhdp/bin #shell脚本存放目录
dhdp_data_dir=/home/hadoop/dhdp/data #数据目录
dhdp_conf_dir=/home/hadoop/dhdp/conf #最新的配置文件存放目录
dhdp_core_dir=/home/hadoop/dhdp/core #大数据组件安装目录
dhdp_log_dir=/home/hadoop/dhdp/logs #集群存放日志
dhdp_package_dir=/home/hadoop/dhdp/tools #安装包存放目录

function format_hadoop(){
	echo "[+] formatted cluster begin ..."
	#必须使用hadoop用户执行集群格式化
	if [ "x$USER" != "xhadoop" ];then
		echo "[-] format cluster must be using the hadoop user ..."
		return
	fi

	#只在hadoop01节点上执行集群格式化
	if [ "x$HOSTNAME" != "xhadoop01" ];then
		echo "[-] Please execute format cluster on the hadoop01 node ..."
		return
	fi

	#集群中各主机IP数组
    IPs_str=`sed -n 3,5p /etc/hosts | awk '{print $1}'`
	#将IP字符串转化为数组
	IPs_arr=($IPs_str)
	#格式化集群之前先kill掉集群中正在运行的进程
	pssh -H "$IPs_str" -t 10000 -l hadoop -i "bash $dhdp_bin_dir/dhdp_start_or_stop_hadoop.sh kill dfs"
	pssh -H "$IPs_str" -t 10000 -l hadoop -i "bash $dhdp_bin_dir/dhdp_start_or_stop_hadoop.sh kill zookeeper"
	pssh -H "$IPs_str" -t 10000 -l hadoop -i "bash $dhdp_bin_dir/dhdp_start_or_stop_hadoop.sh kill hbase"
	pssh -H "$IPs_str" -t 10000 -l hadoop -i "bash $dhdp_bin_dir/dhdp_start_or_stop_hadoop.sh kill yarn"
	pssh -H "$IPs_str" -t 10000 -l hadoop -i "bash $dhdp_bin_dir/dhdp_start_or_stop_hadoop.sh kill mysql"

	#格式化hadoop集群之前先启动zk和journalnode
	pssh -H "$IPs_str" -t 10000 -l hadoop -i "zkServer.sh start"
	hadoop-daemons.sh start journalnode
	#在格式化集群之前删除可能存在的过期数据目录
	pssh -H "$IPs_str" -t 10000 -l hadoop -i "rm -rf $dhdp_data_dir/hadoop"

		#进行格式化
	echo "[+] namenode format ..."
	hadoop namenode -format
	#将hadoop01上生成的元数据目录远程发送到hadoop02上
	scp -r $dhdp_data_dir/hadoopdata hadoop02:$dhdp_data_dir
	#格式化zk
	echo "[+] zkfc format ..."
	hdfs zkfc -formatZK
	#初始化hive元数据库
	cd $dhdp_core_dir/hive/bin && schematool -dbType mysql -initSchema
	echo "[+] formatted cluster end ..."
}
#初始化HDFS资源
function init_hdfs_resource(){
	echo "[+] init_hdfs_resource start ..."
	#必须使用hadoop用户执行HDFS资源初始化
	if [ "x$USER" != "xhadoop" ];then
		echo "[-] init_hdfs_resource must be using the hadoop user ..."
		return
	fi

	#只在hadoop01节点上执行HDFS资源初始化
	if [ "x$HOSTNAME" != "xhadoop01" ];then
		echo "[-] Please execute init_hdfs_resource on the hadoop01 node ..."
		return
	fi

	#先启动hdfs相关进程
	start-dfs.sh
	#初始化hdfs上spark的历史服务器日志文件目录
    echo "[+] mkdir spark historyserver log directory ..."
	hadoop fs -mkdir -p /sparklog
	#初始化完成后关闭hdfs进程
	stop-dfs.sh
	echo "[+] init_hdfs_resource end ..."
}


#拷贝conf目录下配置文件到core/各组件中

function copy_resource_to_every_component(){
	echo "[+] copy_resource_to_every_component start ..."
	#配置hadoop用户下的.bashrc环境变量文件,\cp不提示直接删除
	\cp -f $dhdp_conf_dir/ops/bashrc /home/hadoop/.bashrc
	chown hadoop:hadoop /home/hadoop/.bashrc && source /home/hadoop/.bashrc
	chmod 750 /home/hadoop
	#复制conf目录下对应组件的最新配置文件到对应位置目录下
	cp $dhdp_conf_dir/hadoop/* $dhdp_core_dir/hadoop/etc/hadoop
	cp $dhdp_conf_dir/hbase/* $dhdp_core_dir/hbase/conf
	cp $dhdp_conf_dir/hive/* $dhdp_core_dir/hive/conf
	cp $dhdp_conf_dir/zookeeper/* $dhdp_core_dir/zookeeper/conf
	cp $dhdp_conf_dir/spark/* $dhdp_core_dir/spark/conf
	chown -R hadoop:hadoop $dhdp_core_dir
	cp $dhdp_conf_dir/hadoop_compile/* $dhdp_core_dir/hadoop/bin

	#处理集群中组件的特殊文件配置
	handle_special_config

}

#处理集群中组件的特殊文件配置
host_name="hadoop02,hadoop03"
function handle_special_config(){
    echo "$1"  >> /etc/hostname
    myid = 1
    for hostname in ${host_name[@]};
    do
        ((myid++))
        echo $myid  $host_name > $dhdp_data_dir/zookeeper/myid
        /usr/bin/expect<<-EOF
        ssh $host_name
        expect {
		    *(yes/no)* {send -- yes\r;exp_continue;}
			*password:* {send -- root\r;exp_continue;}
			sed -i "s!broker.id=1!broker.id=$myid!g" $KAFKA_HOME/config/server.properties
		    sed -i "s!host.name=hadoop01!host.name=$host_name!g" $KAFKA_HOME/config/server.properties
		    sed -i "s!advertised.listeners=PLAINTEXT://hadoop01:9092!advertised.listeners=PLAINTEXT://$host_name:9092!g" $KAFKA_HOME/config/server.properties
		}

		EOF
    done
	
}
function main(){
	if [ "x$1" == "xformat" ];then
		format_hadoop
	elif [ "x$1" == "xcopy_resource" ];then
		copy_resource_to_every_component
	elif [ "x$1" == "xinit_hdfs" ];then
		init_hdfs_resource
	elif [ "x$1" == "xspecial_config" ];then
		handle_special_config
	else
		echo '[-] Usage: dhdp_each_host_init_resoure.sh [mode]'
		echo '[-] ERROR:[mode] should be in (format | copy_resource | init_hdfs | special_config)'
		return
	fi
}
main $1
