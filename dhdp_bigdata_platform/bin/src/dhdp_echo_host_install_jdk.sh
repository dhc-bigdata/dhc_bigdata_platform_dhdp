#!/bin/bash


################################################################################
## 1.指定安装jdk的版本:例如jdk-8u172-linux-x64.tar.gz
## 2.指定jdk安装位置：$java_install_dir
## 3.安装必须使用root用户
## 4.该安装脚本只需要将jdk对应版本的tar.gz的安装包放在$java_install_dir下即可
################################################################################


#java_version=$2
#安装jdk的包名
java_install_package_name=jdk-8u172-linux-x64.tar.gz
#安装jdk的默认安装目录
java_install_dir=/home/hadoop/core
#jdk的安装包的存放位置
java_install_package=/home/hadoop/package

#安装jdk
function install_each_host_jdk(){
        echo "[+] The function install_each_host_jdk begin......"
    #param=`echo $java_version | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9\_]\{1,5\}$"`

	    #1.判断安装目录是否存在删除安装目录和环境变量
		if [ -n "$java_install_dir" ];
			then
			echo "[-] This file already exist and need to delete......"
			
		#删除已经存在的安装目录和环境变量
		rm -rf  $java_install_dir 
        #2.创建jdk的安装包存放目录
		groupadd hadoop && useradd -r -g hadoop hadoop
        mkdir -p $java_install_dir
		chown R hadoop:hadoop $java_install_dir

        #3.解压$install_package目录下$java_install_package_name到安装目录下
        tar -zxf $java_install_package/$java_install_package_name -C $java_install_dir

        #4.更改解压后的java文件夹名称
        cd $java_install_dir
        java_version=`ls | grep jdk`

        

        #5.添加java的环境变量并刷新hadoop用户环境变量配置文件
        echo -e "\nexport JAVA_HOME=$java_install_dir/$java_version" >> /home/hadoop/.bashrc
        echo -e 'export PATH=$PATH:$JAVA_HOME/bin' >> /home/hadoop/.bashrc
        source /home/hadoop/.bashrc 
		
		java -version
		
		echo "[+] The function install_each_host_jdk end......"
			
			return
		fi
		
        #6.将本地java目录及环境变量复制到其他虚拟机
        #scp $java_install_dir/java-$java_version root@192.168.120.204:$java_install_dir/java-$java_version
        #scp $java_install_dir/java-$java_version root@192.168.120.204:$java_install_dir/java-$java_version
        #scp /home/dhdp/.bashrc root@192.168.120.204:/home/dhdp/.bashrc
        #scp /home/dhdp/.bashrc root@192.168.120.204:/home/dhdp/.bashrc
}
install_each_host_jdk