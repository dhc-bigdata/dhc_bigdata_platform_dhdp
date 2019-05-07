#! /bin/bash
#文本及脚本文件格式如windows转Unix参考命令dos2unix
#-e 转义反斜扛字符 -n 禁止换行 \b 删除前一个字符 \n 换行且光标移至行首
IFS=$(echo -en "\n\b")
function Doc2Unix(){
	for file in $1/*; do
		dos2unix $file
		echo 'converting '$file
	done
}
Doc2Unix $1

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

	mount -o loop -t iso9660 /root/dhdp/CentOS-7-x86_64-DVD-1810.iso /media
	
	mkdir -p /etc/yum.repos.d/bak
	cd /etc/yum.repos.d/
	cp *.repo ./bak
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
	
	sed -i '/enabled=0/i\name=' CentOS-Base.repo
	
	yum clean all
	
	yum makecache
	
	yum repolist all

}
if [ $hostname == "hadoop01" ];then
	sync_time
else
   echo "0-59/1 * * * * /usr/sbin/ntpdate hadoop01" > crontab
fi

