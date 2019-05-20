#!/bin/bash
#使用root用户操作
echo 'execute dhdp_install_pssh.sh begin ...'
    if [ "x$USER" != "xroot" ];then
        echo "[-] Install using the root user..."
        exit 1
    fi


    version=2.3.1
    version_own=`pssh --version 2>&1`	#python version是错误输出，不是标准输出

    if [[ x$version_own == x*$version* ]];then
	    echo "pssh is already install. version: $version_own"
	    cd /home/hadoop/dhdp/tools/package/ && rm -rf pssh-2.3.1	#将可能存在的垃圾文件删除
	    exit 0
    fi

    cd /home/hadoop/dhdp/tools/package/ && tar -zxf pssh-2.3.1.tar.gz && cd pssh-2.3.1
    python setup.py install
    cd /home/hadoop/dhdp/tools/package/ && rm -rf pssh-2.3.1

    echo 'pssh version:'
    pssh --version
    echo ''

    echo 'execute dhdp_install_pssh.sh end ...'