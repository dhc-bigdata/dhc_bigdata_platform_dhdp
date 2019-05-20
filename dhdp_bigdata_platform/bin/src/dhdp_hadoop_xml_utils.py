#!/usr/bin/python
#coding=utf-8
#配置集群配置文件xml文件,格式：配置主机IP、主机名、用户、密码、内存、进程

from xml.dom.minidom import parse
import xml.dom.minidom, sys
class XmlUtils:
        #读取xml文件得到每个host的hosts
        def read_xml_hosts(self):
                docxml = xml.dom.minidom.parse("/home/hadoop/dhdp/conf/conf_ops/dhdp_hosts.xml")  #加载xml文件 路径需要改动
                root = docxml.documentElement  # 获取元素的根节点
                hosts = root.getElementsByTagName('host')  #获取子节点数组
                return hosts
        #读取集中的所有IP地址
        def getcluster_IPs(self, hosts):
                IPList = []
                #对所有的子节点进行遍历
                for host in hosts:
                        # 根据标签名输出第一个元素
                        IP = host.getElementsByTagName("IP")[0]
                        # 输出标签名的子节点的第一个值，并转为data类型
                        IPList = IP.childNodes[0].data
                        print IPList

        #读取集的所有hostname
        def getcluster_hostname(self, hosts):
                for host in hosts:
                        hostname = host.getElementsByTagName("hostname")[0]
                        hostNameList =hostname.childNodes[0].data
                        print hostNameList

        #读取集的各节点的root密码
        def getcluster_root_passwd(self, hosts):
                rootPasswd = ''
                host = hosts[0]
                password_root = host.getElementsByTagName("password_root")[0]
                rootPasswd = password_root.childNodes[0].data
                print rootPasswd
        # 读取群的各节点的hadoop密码
        def getcluster_hadoop_passwd(self, hosts):
                hadoopPasswd = ''
                host = hosts[0]
                password_hadoop = host.getElementsByTagName("password_hadoop")[0]
                hadoopPasswd = password_hadoop.childNodes[0].data
                print hadoopPasswd
        #读取集的各节点的memory大小
        def getcluster_memory_size(self, hosts):
                for host in hosts:
                        memory = host.getElementsByTagName("memory")[0]
                        memoryList = memory.childNodes[0].data
                        print memoryList
        #读取集的各节点的processes列表
        def getcluster_processes(self, hosts):
                for host in hosts:
                        process = host.getElementsByTagName("processes")[0]
                        processesList = process.childNodes[0].data
                        print processesList

        #根据参确定调用对应的方法处理
        def gethostname_by_IP(self, hosts, IP):
                hostname =''
                for host in hosts:
                        IPTag = host.getElementsByTagName("IP")[0]
                        IPData = IPTag.childNodes[0].data
                        if IPData == sys.argv[1]:
                                hostNameTag = host.getElementsByTagName("hostname")[0]
                                hostname = hostNameTag.childNodes[0].data
                print hostname
        #根据参调用对应的方法
        def gethostnamelist_by_process(self, hosts, process):
                processesList = []
                for host in hosts:
                        process = host.getElementsByTagName("processes")[0]
                        processesList = process.childNodes[0].data
                        if sys.argv[1] in processesList:
                                hostname = host.getElementsByTagName("hostname")[0]
                                hostNameList = hostname.childNodes[0].data
                                print hostNameList

        #根据参确定调用对应的方法处理
        def hanle_method_by_params(self, argv):
                method_name = argv[1]
                function_params = argv  #定义方法参数
                del function_params[0]
                hosts = self.read_xml_hosts()
                result = ''
                if method_name == "IPs":
                        result = self.get_cluster_IPs(hosts)
                elif method_name == "hostname":
                        result = self.get_cluster_hostname(hosts)
                elif method_name == "root_password":
                        result = self.get_cluster_root_passwd(hosts)
                elif method_name == "hadoop_password":
                        result = self.get_cluster_hadoop_passwd(hosts)
                elif method_name == "memory":
                        result = self.get_cluster_memory_size(hosts)
                elif method_name == "processes":
                        result = self.get_cluster_processes(hosts)
                elif method_name == "get_hostname_by_IP":
                        result = self.get_hostname_by_IP(hosts, function_params[0])
                elif method_name == "get_hostnamelist_by_process":
                        result = self.get_hostnamelist_by_process(hosts, function_params[0])
                else:
                        print("[-] can not found function name match : " + method_name)
                        sys.exit(-1)  #所有程序（方法，类等）停止，系统停止运行； sys.exit(0)正常退出
                return result

if __name__ == '__main__':
        xmlutil = XmlUtils()
        result = xmlutil.handle_method_by_params(sys.argv)
        result