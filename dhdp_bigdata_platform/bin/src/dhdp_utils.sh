#! /bin/bash
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
   mv CentOS-Media.repo CentOS-Media.repo_bak
   touch CentOS-Media.repo
   echo "
[centos7-media]

name=centos7

baseurl=file:///media/CentOS7

enabled=1

gpgcheck=0

gpgkey=file:///media/CentOS7/RPM-GPG-KEY-CentOS-7
" >> CentOS-Media.repo
   mv CentOS-Base.repo CentOS-Base.repo.bak

   yum makecache


}

function init_hostname(){
	ips=`获取ips脚本`
	/usr/bin/expect <<EOF
		set timeout 120
		
		for ip in $ips;do
			spawn ssh -o stricthostkeychecking=no root@$ip
			expect {
					"(yes/no)" {send "yes\r"; exp_continue}
					"password:" {send "${root_password}\n; exp_continue"}
			}
			expect "]#"  {send "echo $ip > /etc/hosts \n"}
			expect "]#"  {send "exit\n"}
			#expect eof
		done
EOF

}

function ssh_key_gen(){
		rm -rf /root/.ssh
		/usr/bin/expect <<-EOF
		set timeout 300
		spawn ssh-keygen -t rsa
		expect {
				*(/root/.ssh/id_rsa)* {send -- \r;exp_continue;}
				*passphrase)*	{send -- \r;exp_continue;}
				*again*	 {send -- \r;exp_continue;}
		}
		EOF
		
}

function ssh_copy_id(){
		/usr/bin/expect <<-EOF
		set timeout 300
			spawn ssh-copy-id $1
		expect {
				*(yes/no)* {send -- yes\r;exp_continue;}
				*password:* {send -- root\r;exp_continue;}
		}
		EOF
}
function ssh_copy_id_all(){
		SERVERS=`获取主机名`
		for SERVER in $SERVERS
		do
			ssh_copy_id $SERVER
		done
}

