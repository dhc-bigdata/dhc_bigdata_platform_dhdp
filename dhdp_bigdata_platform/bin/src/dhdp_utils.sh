#! /bin/bash

#定义脚本变量
dhdp_home=/home/hadoop/dhdp
#获取集群主机名
hosts=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
ips=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py IPs`
iphosts=`python $dhdp_home/bin/src/dhdp_read_ip_hostname.py`
hostname=hadoop0
hpid=0

#文本及脚本文件格式如windows转Unix参考命令dos2unix
#-e 转义反斜扛字符 -n 禁止换行 \b 删除前一个字符 \n 换行且光标移至行首
IFS=$(echo -en "\n\b")
function Doc2Unix(){
	for file in $1/*; do
		dos2unix $file
	done
}

#时间同步	
function sync_time(){
    echo "sync_time begin......"
    rm -rf /etc/ntp.conf
    cp /home/hadoop/dhdp/conf/sync_time/ntp.conf /etc
    echo "SYNC_HWCLOCK=yes
    OPTIONS='-u ntp:ntp -p /var/run/ntpd.pid -g'"  >  /etc/sysconfig/ntpd
    systemctl disable ntpd.service
    systemctl enable ntpd.service
	echo " "
    echo "sync_time end......"
}

#挂载镜像
function mount_os(){
    mkdir -p /media/CentOS7
    mount -o loop -t iso9660 /root/dhdp/CentOS-7-x86_64-DVD-1810.iso /media/CentOS7
    ##在/etc/fstab文件里最后一行添加这行代码

    echo "
    /root/dhdp/CentOS-7-x86_64-DVD-1810.iso /media/CentOS7 iso9660 defaults,ro,loop 0 0
    " >>  /etc/fstab
    cd /etc/yum.repos.d/
    if [ ! -f "$CentOS-Media.repo_bak" ]; then
        mv CentOS-Media.repo CentOS-Media.repo_bak
    else
        rm -rf CentOS-Media.repo_bak
        mv CentOS-Media.repo CentOS-Media.repo_bak
    fi

    if [ ! -f "$CentOS-Media.repo" ]; then
        touch CentOS-Media.repo
    else
        rm -rf CentOS-Media.repo
        touch CentOS-Media.repo
    fi

    echo "
centos7-media]

ame=centos7

aseurl=file:///media/CentOS7

nabled=1

pgcheck=0

pgkey=file:///media/CentOS7/RPM-GPG-KEY-CentOS-7
 >> CentOS-Media.repo
    mv CentOS-Base.repo CentOS-Base.repo.bak

    yum makecache


}


function init_hosts(){
    echo "$iphosts" >> /etc/hosts

    for ip in $ips;do
        /usr/bin/expect <<-EOF
        set timeout 300
        spawn scp /etc/hosts root@$ip:/etc
        expect {
				*(yes/no)* {send -- yes\r;exp_continue;}
				*password:* {send -- root\r;exp_continue;}
        }
		EOF
    done
}

function init_hostname(){
	rm -rf /root/.ssh
        for ip in $ips;do
			((hpid++))
			/usr/bin/expect <<-EOF
			set timeout 300
			spawn ssh -o stricthostkeychecking=no root@$ip
			expect {
					"(yes/no)" {send "yes\r"; exp_continue}
					"password:" {send "root\n; exp_continue"}
			}
			expect "]#"  {send "rm -rf /root/.ssh \n"}
			expect "]#"  {send "echo '$hostname$hpid'  > /etc/hostname \n"}
			expect "]#"  {send "exit\n"}
			#expect eof
			EOF
		done
}


