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
mkdir mkdir

mount -o loop -t iso9660 CentOS-7-x86_64-Everything-1611.iso /media

jinrin n /etc/yum.repos.dwenjismk

rm  -f ./CentOS-Media.repo
touch  ./CentOS-Media.repo

echo "
[CentOS 7.3 1611]
#命名
name=CentOS-$releasever - Everything_ISO
#该镜像源已启用，若为0，则禁用
enabled=1
#镜像源地址
baseurl=file:///media/Packages/
#启用GPG校验，若为0，则禁用校验
gpgcheck=1
#校验文件（密钥）文件地址
gpgkey=file:///media/RPM-GPG-KEY-CentOS-7
" >> CentOS-Media.repo
