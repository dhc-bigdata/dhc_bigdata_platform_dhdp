#!/bin/bash
ips=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py IPs`
function init_scp(){
	for ip in $ips;
		do
			/usr/bin/expect <<-	EOF
			set timeout 300
				spawn scp /home/hadoop/dhdp/bin/src/dhdp_ssh.sh  hadoop@$ip:/home/hadoop/dhdp/bin/src
			expect {
	                   	 *(yes/no)* {send -- yes\r;exp_continue;}
                                  *password:* {send -- hadoop\r;exp_continue;}
			}
			EOF
		done
}
init_scp
