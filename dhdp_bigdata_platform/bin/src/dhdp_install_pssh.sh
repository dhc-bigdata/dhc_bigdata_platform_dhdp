#!/bin/bash
#############################################################################
#程序名:一键安装pssh
#功能描述:一键安装pssh
#作者:   liukai
#创建日期: 20190424
#输入:     日期 v_data_DATE              ($1)
#输出: res 
#系统变量： 执行上一个指令的返回值     ($?)
#############################################################################
#############################################################################
#  修改者:
#  修改日期:
#  修改内容:
##############################################################################
##下载上传pssh到/usr/local/pssh目录
mkdir /usr/local/pssh
dhdp_home=/home/hadoop/dhdp/core
$2=/usr/local/pssh/pssh-1.4.1
## 将安装包解压到安装位置，不输出日志
tar -xzvf /usr/local/pssh/pssh-1.4.1.tar.gz

##上传setuptools-0.6c11.tar.gz 到/usr/local/pssh/pssh-1.4.1 并解压
tar xzf /usr/local/pssh/pssh-1.4.1/setuptools-0.6c11.tar.gz
cd /usr/local/pssh/pssh-1.4.1/setuptools-0.6c11
python setup.py build
python setup.py install
##进入pssh目录
cd /usr/local/pssh/pssh-1.4.1
python setup.py build
python setup.py install
##在 /root/.ssh/目录下创建rsa.sh test.txt文件
cd  /root/.ssh/
touch rsa.sh
touch test.txt
##服务器ip写入test.txt文件中
echo '192.168.91.131' >>/root/.ssh/test.txt
echo '192.168.91.132' >>/root/.ssh/test.txt
echo '192.168.91.133' >>/root/.ssh/test.txt
 more rsa.sh
#!/bin/sh
#by authors chy 2016
for i in $(cat test.txt)
do
        ssh-copy-id -i /root/.ssh/id_rsa.pub $i
        echo $i"设置密码登录成功"
done

