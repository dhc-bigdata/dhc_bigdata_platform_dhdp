#!/bin/bash
#对集群进行打包操作
#root用户执行
echo 'execute dhdp_package.sh begin ...'
if [ "x$USER" != "xroot" ];then
	echo "[-] Install using the root user..."
	exit 1
fi
#读取集群版本
version=`cat /home/hadoop/dhdp/conf/conf_ops/dhdp_version`
dhdp_dir=/home/hadoop/dhdp
tar_dhdp_name="dhdp-"$version
full_dhdp_dir=/home/hadoop/$tar_dhdp_name

#删除集群不用文件
rm -rf $full_dhdp_dir && mkdir -p $full_dhdp_dir
cd /home/hadoop/dhdp/ && cp -rv bin conf tools share README.md $full_dhdp_dir

#处理bin、conf下换行符格式
dos2unix /home/hadoop/dhdp/bin/*.sh
. $dhdp_dir/bin/src/dhdp_utils.sh && Doc2Unix $full_dhdp_dir/bin/src/
confs=`ls $dhdp_dir/conf`
for conf_dir in $confs;do
	. $dhdp_dir/bin/src/dhdp_utils.sh && Doc2Unix $dhdp_dir/conf/$conf_dir
done
#打包前处理用户组权限
chown -R hadoop:hadoop $full_dhdp_dir

mkdir -p $full_dhdp_dir/core && cd /home/hadoop/dhdp/core && cp -r hadoop hbase hive jdk kafka spark zookeeper $full_dhdp_dir/core/


#进行打包
cd /home/hadoop && tar -zcvf $tar_dhdp_name".tar.gz" $tar_dhdp_name && mv $tar_dhdp_name".tar.gz" /root/dhdp/ && rm -rf $tar_dhdp_name

echo 'execute dhdp_package.sh end ...'
