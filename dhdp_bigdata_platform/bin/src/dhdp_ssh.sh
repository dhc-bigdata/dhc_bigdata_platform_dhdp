#!/bin/bash
hosts=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
ips=hosts=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py IPs`
function ssh_key_gen(){
                /usr/bin/expect <<-EOF
                set timeout 300
                spawn ssh-keygen -t rsa
                expect {
                                *(/root/.ssh/id_rsa)* {send -- \r;exp_continue;}
                                *passphrase)*   {send -- \r;exp_continue;}
                                *again*  {send -- \r;exp_continue;}
                }
				EOF
}

function ssh_copy_id_root(){
                /usr/bin/expect <<-EOF
                set timeout 300
                        spawn ssh-copy-id $1
                expect {
                                *(yes/no)* {send -- yes\r;exp_continue;}
                                *password:* {send -- root\r;exp_continue;}
                }
				EOF
}
function ssh_copy_id_all_root(){
                for host in $hosts
                do
                        ssh_copy_id $host
                done
}
function ssh_copy_id_hadoop(){
                /usr/bin/expect <<-EOF
                set timeout 300
                        spawn ssh-copy-id $1
                expect {
                                *(yes/no)* {send -- yes\r;exp_continue;}
                                *password:* {send -- hadoop\r;exp_continue;}
                }
				EOF
}

function ssh_copy_id_all_hadoop(){
                for host in $hosts
                do
                        ssh_copy_id $host
                done
}
function ssh_local(){
	. /home/hadoop/dhdp/bin/src/dhdp_ssh.sh && ssh_key_gen
	. /home/hadoop/dhdp/bin//src/dhdp_ssh.sh && ssh_copy_id_all_root
	su - hadoop <<-EOF
			. /home/hadoop/dhdp/bin/src/dhdp_ssh.sh && ssh_key_gen
			. /home/hadoop/dhdp/bin/src/dhdp_ssh.sh && ssh_copy_id_all_hadoop
			EOF
}
