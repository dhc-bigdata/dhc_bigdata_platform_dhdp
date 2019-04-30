#!/bin/bash


################################################################################
## 1.指定安装jdk的版本:例如jdk-8u172-linux-x64.tar.gz
## 2.指定jdk安装位置：$java_install_dir
## 3.安装必须使用root用户
## 4.该安装脚本只需要将jdk对应版本的tar.gz的安装包放在$java_install_dir下即可
################################################################################

#安装jdk的包名
java_install_package_name=jdk-8u172-linux-x64.tar.gz
#安装jdk的默认安装目录
java_install_dir=/home/hadoop/dhdp/core/
#jdk的安装包的存放位置
java_install_package=/home/hadoop/dhdp/tools

#安装jdk
function install_each_host_jdk(){
        echo "[+] The function install_each_host_jdk begin......"

	    #1.判断安装目录是否存在删除安装目录和环境变量
		if [ -n "$java_install_dir/jdk" ];then

		    echo "[-] This file already exist and need to delete......"
		fi
		#2删除已经存在的安装目录和环境变量
        rm -rf  $java_install_dir/jdk
        #3.解压$install_package目录下$java_install_package_name到安装目录下
        tar -zxf $java_install_package/$java_install_package_name -C $java_install_dir
        #4.更改解压后的java文件夹名称
        cd $java_install_dir
        java_version=`ls | grep jdk`
        mv  $java_version  jdk
        #显示jdk版本
        $java_install_dir/jdk/bin/java -version
        echo "[+] The function install_each_host_jdk end......"
   }
install_each_host_jdk