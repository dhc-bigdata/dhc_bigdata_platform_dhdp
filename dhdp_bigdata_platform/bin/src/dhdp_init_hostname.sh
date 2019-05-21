#!/bin/bash
dhdp_home=/home/hadoop/dhdp
#获取集群主机名
hosts=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py hostname`
ips=hosts=`python $dhdp_home/bin/src/dhdp_hadoop_xml_utils.py IPs`
iphosts=`python $dhdp_home/bin/src/dhdp_read_ip_hostname.py`
hostname=hadoop0
hpid=0
function init_hostname(){

        echo "$iphosts" >> /etc/hosts

        for ip in $ips;
                do
                        /usr/bin/expect <<-EOF
                        set timeout 300
                                spawn scp /etc/hosts root@$ip:/etc
                        expect {
#                                *(yes/no)* {send -- yes\r;exp_continue;}
                                  *password:* {send -- root\r;exp_continue;}
                        }
						EOF
                done
}
function init_host(){
        for ip in $ips;
                do
                        ((hpid++))
                        /usr/bin/expect <<-EOF
                                        set timeout 300
                                        spawn ssh -o stricthostkeychecking=no root@$ip
                        expect {
        #                               "(yes/no)" {send "yes\r"; exp_continue}
                                        "password:" {send "root\n; exp_continue"}
                        }
                        expect "]#"  {send "echo '$hostname$hpid'  >> /etc/hostname \n"}
                        expect "]#"  {send "exit\n"}
                        #expect eof
						EOF
                done
}
init_hostname
init_host
