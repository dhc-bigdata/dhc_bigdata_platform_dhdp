#!/bin/bash
#hosts=hosts=`python dhdp_hadoop_xml_utils.py hostname`
#ips=`python dhdp_hadoop_xml_utils.py IPs`
ips="192.168.120.115 192.168.120.116"
hosts="hadoop01 hadoop02"
ssh_three
function ssh_three(){
for ip in $ips;
                do
                        /usr/bin/expect <<-EOF
                                        set timeout 300
                                        spawn ssh -o stricthostkeychecking=no root@$ip
                        expect {
        #                               "(yes/no)" {send "yes\r"; exp_continue}
                                          password:" {send "root\n; exp_continue"}
                        }
                        expect "]#"  {send "rm -rf /root/.ssh \n"}
                        expect "]#"  {send ". dhdp_utils.sh && ssh_key_gen \n"}
		                expect "]#"  {send ". dhdp_utils.sh && ssh_copy_id_all \n"}
                        expect "]#"  {send "exit\n"}
                        #expect eof
						EOF
                done
}
function ssh_key_gen(){
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
		for host in $hosts
		do
			ssh_copy_id $host
		done
}
