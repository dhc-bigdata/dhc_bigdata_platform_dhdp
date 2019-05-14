#!/bin/bash

dhdp_data_dir=/home/hadoop/dhdp/data #数据目录
dhdp_log_dir=/home/hadoop/dhdp/logs #集群存放日志

ips=`python dhdp_hadoop_xml_utils.py IPs`

function init_resource(){

for ip in $ips;
do
/usr/bin/expect <<EOF
	set timeout 120
	spawn ssh -o stricthostkeychecking=no root@$ip
	expect {
			"(yes/no)" {send "yes\r"; exp_continue}
			"password:" {send "$root\n; exp_continue"}
	}
	#删除相应的目录
	expect "]#"  {send "rm -rf $dhdp_data_dir/*\n "}
	expect "]#"  {send "rm -rf $dhdp_log_dir/*\n"}
	#创建相应组件下的日志文件
	expect "]#"  {send "mkdir -p $dhdp_log_dir/hadoop\n "}
	expect "]#"  {send "mkdir -p $dhdp_log_dir/yarn\n"}
	expect "]#"  {send "mkdir -p $dhdp_log_dir/zookeeper\n"}
	expect "]#"  {send "mkdir -p $dhdp_log_dir/hbase\n"}
	expect "]#"  {send "mkdir -p $dhdp_log_dir/kafka\n"}
	expect "]#"  {send "mkdir -p $dhdp_log_dir/hive\n"}
	expect "]#"  {send "mkdir -p $dhdp_log_dir/spark\n"}
	#创建相应组件下的数据文件
	expect "]#"  {send "mkdir -p $dhdp_data_dir/hadoop\n"}
	expect "]#"  {send "mkdir -p $dhdp_data_dir/yarn\n"}
	expect "]#"  {send "mkdir -p $dhdp_data_dir/zookeeper\n"}
	expect "]#"  {send "mkdir -p $dhdp_data_dir/hbase\n"}
	expect "]#"  {send "mkdir -p $dhdp_data_dir/kafka\n"}
	expect "]#"  {send "mkdir -p $dhdp_data_dir/hive\n"}
	expect "]#"  {send "mkdir -p $dhdp_data_dir/spark\n"}
	#expect eof
EOF
done
}




















