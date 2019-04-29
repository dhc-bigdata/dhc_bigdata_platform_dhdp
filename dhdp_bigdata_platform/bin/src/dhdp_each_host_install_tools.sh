#!/bin/bash
#安装基础软件、以及工具  比如pssh、java、mysql

dhdp_bin_dir=/home/hadoop/dhdp/bin/

hostname=`hostname`

#只在最后一台机器安装
if [ $hostname == "hadoop03" ];then
    cd $dhdp_bin_dir && bash dhdp_install_mysql.sh
fi