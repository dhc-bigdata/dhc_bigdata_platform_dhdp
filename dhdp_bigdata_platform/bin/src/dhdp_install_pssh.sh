#!/bin/bash
#############################################################################
#程序名:一键安装pssh
#功能描述:一键安装pssh
#作者:   liukai
#创建日期: 20190424
#输入:     日期 v_data_DATE              ($1)
#输出: res 
#系统变量： 执行上一个指令的返回值     ($?)
#############################################################################
#############################################################################
#  修改者:
#  修改日期:
#  修改内容:
##############################################################################
##下载上传pssh到/usr/local/pssh目录
mkdir /usr/local/pssh
pssh_install_dir=/home/hadoop/core
echo 'execute dhdp_install_pssh.sh start ...'
## 将安装包解压到安装位置，不输出日志
tar -xzvf /home/hadoop/core/pssh-1.4.1.tar.gz

##上传setuptools-0.6c11.tar.gz 到/usr/local/pssh/pssh-1.4.1 并解压
tar xzf /home/hadoop/core/pssh-1.4.1/setuptools-0.6c11.tar.gz
cd /home/hadoop/core/pssh-1.4.1/setuptools-0.6c11
python setup.py build
python setup.py install
##进入pssh目录
cd /home/hadoop/core/pssh-1.4.1
python setup.py build
python setup.py install

##查看版本号
pssh --version
echo 'execute dhdp_install_pssh.sh end ...'
