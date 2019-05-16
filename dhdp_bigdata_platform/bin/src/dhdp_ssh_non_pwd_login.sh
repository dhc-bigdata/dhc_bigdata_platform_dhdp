#!/bin/bash
SERVERS="hadoop01  hadoop02  hadoop03"
#password=root
rm -rf /root/.ssh
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
		for SERVER in $SERVERS
		do
			ssh_copy_id $SERVER
		done
}
ssh_key_gen
ssh_copy_id_all
