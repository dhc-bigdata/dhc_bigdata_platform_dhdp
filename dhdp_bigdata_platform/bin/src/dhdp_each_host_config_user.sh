#！/bin/bash

user=hadoop
dhdp_home=/home/hadoop/dhdp
#创建用户

if [ "x$USER" != "xroot" ];then
	echo "[-] Install using the root user..."
	exit 1
fi

function config_user(){

	/usr/bin/expect <<-EOF
	set timeout 120
	spawn passwd $user
	#expect "*ssh/id_rsa):" {send "$user\n"}
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

	chown -R $user:$user /home/$user
	chmod -R 750 /home/$user

}

