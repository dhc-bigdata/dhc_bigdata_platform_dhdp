#!/bin/bash
##下载上传pssh到/usr/local/pssh目录
dhdp_package_dir=/home/hadoop/dhdp/tools/package #安装包存放目录
echo 'execute dhdp_install_pssh.sh start ...'
## 将安装包解压到安装位置，不输出日志
cd /home/hadoop/dhdp/tools/package
tar -xzvf /home/hadoop/dhdp/tools/package/pssh-1.4.1.tar.gz
##上传setuptools-0.6c11.tar.gz 到/usr/local/pssh/pssh-1.4.1 并解压
tar -xzvf /home/hadoop/dhdp/tools/package/setuptools-0.6c11.tar.gz
cd /home/hadoop/dhdp/tools/package/setuptools-0.6c11
python setup.py build
python setup.py install
##进入pssh目录
cd /home/hadoop/dhdp/tools/package/pssh-1.4.1
python setup.py build
python setup.py install

##查看版本号
pssh --version
echo 'execute dhdp_install_pssh.sh end ...'
