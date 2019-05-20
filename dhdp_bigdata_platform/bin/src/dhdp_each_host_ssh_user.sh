#!/bin/bash
dhdp_home=/home/hadoop/dhdp
hostname1s=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
hostname2s=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
hostname3s=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
hostname4s=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
hostname5s=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
function ssh_user(){
	ssh_key_gen
	for hostname1 in $hostname1s;do
	    ssh_copy_id $1 $hostname1
	done
}
function ssh_first(){
	for hostname2 in $hostname2s;do
		/usr/bin/expect <<-EOF
			spawn ssh -o stricthostkeychecking=no $1@$hostname2
			expect {
					*(yes/no)* {send -- yes\r;exp_continue;}
					*password:* {send -- $1\r;exp_continue;}
			}
			expect *]*  {send "rm -rf ~/.ssh \n"}
			expect *]*  {send "exit\n"}
			expect eof
		EOF
	done
}
function ssh_other(){
	for hostname3 in $hostname3s;do
		if [ "$hostname3" != "hadoop01" ];then
			/usr/bin/expect <<-EOF
				spawn ssh -o stricthostkeychecking=no $1@$hostname3
				expect *]*  {send "ssh-keygen -t rsa\n"}
				expect {
						 */.ssh/id_rsa)* {send -- \r;exp_continue;}
						 *passphrase)*   {send -- \r;exp_continue;}
						 *again*  {send -- \r;exp_continue;}
						}
				expect *]*  {send "exit\n"}
				expect eof
			EOF
			fi
	done
}

function ssh_all(){
	for hostname4 in $hostname4s;do
		if [ "$hostname4" != "hadoop01" ];then
				for hostname5 in $hostname5s;do
					/usr/bin/expect <<-EOF
					spawn ssh -o stricthostkeychecking=no $1@$hostname4
					expect {
#                           *(yes/no)* {send -- yes\r;exp_continue;}
							*password:* {send -- $1\r;exp_continue;}
					}
					expect *]*  {send "ssh-copy-id $hostname5 \n"}
					expect {
							*(yes/no)* {send -- yes\r;exp_continue;}
							*password:* {send -- $1\r;exp_continue;}
					}
					EOF
				done
		fi
	done
}
function ssh_key_gen(){
	/usr/bin/expect <<-EOF
	set timeout 300
	spawn ssh-keygen -t rsa
	expect {
			*/.ssh/id_rsa)* {send -- \r;exp_continue;}
			*passphrase)*   {send -- \r;exp_continue;}
			*again*  {send -- \r;exp_continue;}
	}
	EOF
}

function ssh_copy_id(){
	/usr/bin/expect <<-EOF
	set timeout 300
	spawn ssh-copy-id $2
	expect {
			*(yes/no)* {send -- yes\r;exp_continue;}
			*password:* {send -- $1\r;exp_continue;}
	}
	EOF
}
ssh_first $1
ssh_user $1
ssh_other $1
ssh_all $1