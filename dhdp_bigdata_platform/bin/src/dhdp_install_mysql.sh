#!/bin/bash
################################################################################
## 1.指定安装mysql的版本：例如mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz
## 2.指定mysql安装位置：$mysql_install_dir
## 3.指定数据库文件数据位置：$mysql_data_dir
## 4.指定mysql日志存放目录：$mysql_log_dir
## 5.安装必须使用root用户
## 6.该安装脚本只需要将mysql对应版本的tar.gz的安装包放在$mysql_install_dir下即可
################################################################################

#安装mysql的默认安装目录、数据文件存放目录及mysql日志存放目录
mysql_version=$2
mysql_install_package_name=mysql-$mysql_version-linux-glibc2.12-x86_64
#mysql的默认安装目录
mysql_install_dir=/home/hadoop/dhdp/core
#mysql数据文件存放目录
mysql_data_dir=/home/hadoop/dhdp/data/mysql
#mysql日志存放目录
mysql_log_dir=/home/hadoop/dhdp/logs/mysql
#mysql安装包存放位置
mysql_install_package=/home/hadoop/dhdp/tools/package
#MySQL配置文件存放目录
mysql_conf=/home/hadoop/dhdp/conf/mysql


#安装mysql
function install_each_host_mysql(){
        echo "[+] The function install_each_host_mysql begin......"
        if [ "x$USER" != "xroot" ];then
            echo "[-] You must use the root user to install this tool ......"
            return
        fi
        if [ -n "$mysql_install_dir/$mysql_version" ];then
                echo "[-] You need delete old file .."
        fi

        #1.删除之前安装可能存在的垃圾目录和文件
        rm -rf $mysql_data_dir && rm -rf $mysql_install_dir/mysql-$mysql_version
        rm -rf /etc/init.d/mysqld && rm -rf $mysql_log_dir

        #2.在hadoop用户家目录下创建数据库数据文件目录$mysql_data_dir和mysql错误日志log-error目录
        mkdir -p $mysql_data_dir && mkdir -p $mysql_log_dir

        #3.上传mysql-$2-linux-glibc2.12-x86_64.tar.gz文件到$install_package下，并进行解压
        if [ ! -f $mysql_install_package/$mysql_install_package_name.tar.gz ];then
            echo "[-] The file $mysql_install_package/$mysql_install_package_name.tar.gz cannot be found ......"
            return
        fi
        echo "[+] execute uncompress tar -zxf $mysql_install_package_name ..."
        tar -xvf $mysql_install_package/$mysql_install_package_name.tar.gz -C  $mysql_install_dir

         #4.更改解压缩后的mysql文件夹名称
         mv $mysql_install_dir/$mysql_install_package_name  $mysql_install_dir/mysql-$mysql_version

         #5.更改指定mysql安装包文件夹及数据库数据文件目录的用户组信息
         chown -R hadoop:hadoop $mysql_install_dir/mysql-$mysql_version
         chown -R hadoop:hadoop $mysql_data_dir
         chown -R hadoop:hadoop $mysql_log_dir

         #6.更改mysql安装文件夹$mysql_install_dir/mysql的权限
         chmod -R 750 $mysql_install_dir/mysql-$mysql_version

         #7.如果没安装，可以用下面命令安装
         yum install -y libaio

         #8.修改mysql配置文件mysql.server
         cp $mysql_conf/mysql.server $mysql_install_dir/mysql-$mysql_version/support-files/mysql.server

         #9.将mysql.server文件复制到/etc/init.d/系统目录下，并修改该文件的执行权限
         cp $mysql_install_dir/mysql-$mysql_version/support-files/mysql.server    /etc/init.d/mysqld
         chmod 750 /etc/init.d/mysqld && chown hadoop:hadoop /etc/init.d/mysqld

         #10.修改my.cnf文件
         cp $mysql_conf/my.cnf /etc/my.cnf && chown hadoop:hadoop /etc/my.cnf
         #11.对mysql进行初始化
         su - hadoop <<-EOF
             bash /home/hadoop/dhdp/bin/src/dhdp_install_mysql.sh init $mysql_version
				EOF
         #12.删除/etc/my.cnf文件中的免密权限校验属性skip-grant-tables并重启服务
          sed -i "s!skip-grant-tables!#skip-grant-tables!g" /etc/my.cnf

          #13.重启使skip-grant-tables权限校验生效并测试mysql是否安装成功
          /etc/init.d/mysqld restart
          if [ $? -eq 0 ];then
          #验证hadoop用户登录并使用mysql是否成功
          $mysql_install_dir/mysql-5.7.22/bin/mysql -uhadoop -phadoop -e "show databases"
             if [ $? -eq 0 ];then
                echo "++++++++++++++++++++++++++ MySQL is Installed and tested successful,END. ++++++++++++++++++++++++++"
             fi
          fi
          chown -R hadoop:hadoop $mysql_data_dir/lockdir
          echo "[+] The function install_each_host_mysql end......"
        }
###安装模式下对mysql进行初始化
function dhdp_each_host_mysql_init(){
         echo "[+] The function dhdp_each_host_mysql_init start......"
         if [ "x$USER" != "xhadoop" ];then
            echo "[-] You must use the hadoop user to initialize mysql ......"
            return
         fi

         #1.服务有可能启动中，需要关闭
        pid=`ps ax | grep port=3306 | grep -v grep | awk '{print $1}'`
        if [ -n "$pid" ];then
            echo 'mysql is running, will stop it in '$pid
            #关闭mysqld_safe
            pid_mysql_sqfe=`ps ax | grep mysqld_safe | grep -v grep | awk '{print $1}'`
            echo $pid_mysql_sqfe
            if [ -n "$pid_mysql_sqfe" ];then
                kill -p $pid_mysql_sqfe
            fi
            #关闭mysqld
            kill -9 $pid
        fi

        #2.对MySQL进行初始化
        cd $mysql_install_dir/mysql-5.7.22/bin
        ./mysqld --user=hadoop --basedir=$mysql_install_dir/mysql-5.7.22 --datadir=$mysql_data_dir --initialize

        #3.因为/etc/init.d/mysqld文件中的lockdir目录是root用户权限，hadoop普通用户重启mysql时无法访问，权限不足,故将lockdir目录迁移到hadoop用户组下
        cd $mysql_data_dir && mkdir -p $mysql_data_dir/lockdir ##该步骤只能放在mysql初始化之后,因为mysql初始化时数据存放目录必须为空

        #4.创建自定义mysqld.pid存放目录$mysql_data_dir/mysqld，必须在初始化之后否则初始化目录不为空会报错
        mkdir -p $mysql_data_dir/mysqld

        #5.该步骤是mysql5.7.22版本的一个小bug,在/etc/my.cnf中配置了log-error文件位置，但不自动生成mysqld.log文件导致后面启动报错
        cd $mysql_log_dir && touch mysqld.log

        #6.启动MySQL服务
        /etc/init.d/mysqld start

        #7.登录mysql修改root用户和hadoop用户的密码并赋予远程访问权限
        /usr/bin/expect <<-EOF
				#set timeout 30
				spawn $mysql_install_dir/mysql-5.7.22/bin/mysql
				expect {
					"*mysql*" {
						send "update mysql.user set host = '%' where user = 'root'; flush privileges; grant all privileges on *.* to 'root'@'%' identified by 'root' with grant option; grant all privileges on *.* to hadoop@'%' identified by 'hadoop'; flush privileges; exit; \r";
					}
				}
				expect eof
				EOF
        echo "[+] The function dhdp_each_host_mysql_init end......"
                                }

 ##该脚本入口方法,$1:需要调用该脚本中的函数名,$2、$3...为调用函数所需的参数
function main(){
        if [ -z "$1" ] || [ -z "$2" ];then
            echo '[-] Usage: dhdp_install_mysql.sh [mode] [mysql_version]'
            echo '[-] explain:mode should be in (install | init) ...'
            return
        fi

        if [ "x$1" == "xinstall" ];then
            install_each_host_mysql
        elif [ "x$1" == "xinit" ];then
            dhdp_each_host_mysql_init
        else
            echo '[-] explain:[mode] should be in (install | init) ...'
            return
        fi
}
main $1 $2