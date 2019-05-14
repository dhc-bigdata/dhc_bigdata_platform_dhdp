#！/bin/bash

user=hadoop
dhdp_home=/home/hadoop/dhdp
#创建用户

if [ "x$USER" != "xroot" ];then
	echo "[-] Install using the root user..."
	exit 1
fi

function config_user(){
	useradd $user

	/usr/bin/expect <<-EOF
	set timeout 120
	spawn passwd $user
	expect "New password:" {send "$user\n"}
	expect "Retype new password:" {send "$user\n"}
	expect eof
	EOF

}

function config_user_group(){
	#将root添加至hadoop组
	usermod root -G hadoop
	#将hadoop用户添加至root组
	usermod hadoop -G root

	cp $dhdp_home/conf/bashrc /home/hadoop/.bashrc
	chown -R $user:$user /home/$user
	chmod -R 750 /home/$user

}

config_user
config_user_group
