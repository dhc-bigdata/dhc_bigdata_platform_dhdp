#!/bin/bash
hnames=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
function ssh_three(){
	. /home/hadoop/dhdp/bin/src/dhdp_ssh.sh && ssh_key_gen
	. /home/hadoop/dhdp/bin/src/dhdp_ssh.sh && ssh_copy_id_all_root
	su - hadoop <<-EOF
			. /home/hadoop/dhdp/bin/src/dhdp_scp.sh
			. /home/hadoop/dhdp/bin/src/dhdp_ssh.sh && ssh_key_gen
			. /home/hadoop/dhdp/bin/src/dhdp_ssh.sh && ssh_copy_id_all_hadoop
			EOF
	for hname in $hnames;
					do
					        if [ "$hname" != "hadoop01" ];then
							/usr/bin/expect <<-EOF
											set timeout 300
											spawn ssh -o stricthostkeychecking=no root@$hname
							expect "]#"  {send ". /home/hadoop/dhdp/bin/src/dhdp_ssh.sh && ssh_local \n"}
							expect "]#"  {send "exit\n"}
							expect eof
				EOF
				            fi
					done
}
ssh_three
