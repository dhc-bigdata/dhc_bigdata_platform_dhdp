#!/bin/bash
hostnames="hadoop01 hadoop02 hadoop03"#hostname
ips="192.168.120.115  192.168.120.116" #主机
function init_hostname(){
	echo "$1"  >> /etc/hostname
	for host in $hostnames and ip in $ips
	do
		echo "$host  $ip"  >> /etc/hosts
	done
}
init_hostname $1

/usr/bin/expect <<EOF
	set timeout 120
	spawn ssh -o stricthostkeychecking=no root@${deploy_ip}
	expect {
			"(yes/no)" {send "yes\r"; exp_continue}
			"password:" {send "${root_password}\n; exp_continue"}
	}
	expect "]#"  {send "mkdir -p ${target_to_path}/$time$dir_name \n"}
	expect "]#"  {send "mkdir -p ${boot_scrpt} \n"}
	expect "]#"  {send "exit\n"}
	#expect eof
EOF