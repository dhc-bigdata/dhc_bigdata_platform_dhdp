#!/bin/bash
hosts=`python dhdp_hadoop_xml_utils.py hostname`
ips=`python dhdp_hadoop_xml_utils.py IPs`
#ips="192.168.120.115 192.168.120.116"
#hosts="hadoop01 hadoop02"
hostname=hadoop0
hpid1=0
hpid2=0
addr=192.168.120.11
arid=4
function init_hostname(){
        for host in $hosts;
                        do
                        ((hpid1++))
                        ((arid++))
                                        echo "$addr$arid  $hostname$hpid1" >> /etc/hosts
                        done
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
                        ((hpid2++))
                        /usr/bin/expect <<-EOF
                                        set timeout 300
                                        spawn ssh -o stricthostkeychecking=no root@$ip
                        expect {
        #                               "(yes/no)" {send "yes\r"; exp_continue}
                                                                        "password:" {send "root\n; exp_continue"}
                        }
                        expect "]#"  {send "echo '$hostname$hpid2'  >> /etc/hostname \n"}
                        expect "]#"  {send "exit\n"}
                        #expect eof
						EOF
                done
}
init_hostname
init_host