#!/usr/bin/python
#coding=utf-8
#配置集群配置文件xml文件,格式：配置主机IP、主机名、用户、密码、内存、进程

from xml.dom.minidom import parse
import xml.dom.minidom, sys
class XmlUtils:
	#读取xml文件得到每个host的hosts
	def read_xml_hosts(self):
		docxml = xml.dom.minidom.parse("/home/hadoop/conf/xml/hlk_hosts.xml")  #加载xml文件 路径需要改动
		root = docxml.documentElement  # 获取元素的根节点
		hosts = root.getElementsByTagName('host')  #获取子节点数组
		return hosts
	#读取集群中的所有IP地址
	def get_cluster_IPs(self, hosts):
		IPList = []
		#对所有的子节点进行遍历
		for host in hosts:
			# 根据标签名输出第一个元素
			IP = host.getElementsByTagName("IP")[0]
			# 输出标签名的子节点的第一个值，并转为data类型
			IPList.append(IP.childNodes[0].data)
		for i in IPList:
			print(i)

	#读取集群的所有hostname
	def get_cluster_hostname(self, hosts):
		hostNameList = []
		for host in hosts:
			hostname = host.getElementsByTagName("hostname")[0]
			hostNameList.append(hostname.childNodes[0].data)
		for i in hostNameList:
			print(i)
	#读取集群的各节点的root密码
	def get_cluster_root_passwd(self, hosts):
		rootPasswd = ''
		host = hosts[0]
		password_root = host.getElementsByTagName("password_root")[0]
		rootPasswd = password_root.childNodes[0].data
		return rootPasswd
	# 读取集群的各节点的hadoop密码
	def get_cluster_hadoop_passwd(self, hosts):
		hadoopPasswd = ''
		host = hosts[0]
		password_hadoop = host.getElementsByTagName("password_hadoop")[0]
		hadoopPasswd = password_hadoop.childNodes[0].data
		return hadoopPasswd
	#读取集群的各节点的memory大小
	def get_cluster_memory_size(self, hosts):
		memoryList = []
		for host in hosts:
			memory = host.getElementsByTagName("memory")[0]
			memoryList.append(memory.childNodes[0].data)
		for i in memoryList:
			print(i)
	#读取集群的各节点的processes列表
	def get_cluster_processes(self, hosts):
		processesList = []
		for host in hosts:
			process = host.getElementsByTagName("processes")[0]
			processesList.append(process.childNodes[0].data)
		for i in processesList:
			print(i)
	#根据参数调用对应的方法
	def get_hostname_by_IP(self, hosts, IP):
		hostname =''
		for host in hosts:
			IPTag = host.getElementsByTagName("IP")[0]
			IPData = IPTag.childNodes[0].data

			if IPData == sys.argv[1]:
				hostNameTag = host.getElementsByTagName("hostname")[0]
				hostname = hostNameTag.childNodes[0].data

		return hostname
	#根据参数调用对应的方法
	def method_by_params(self, argv):
		result = ''
		method_name = argv[1]
		function_params = argv	#定义方法参数
		del function_params[0]
		hosts = self.read_xml_hosts()
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
		else:
			print("[-] can not found function name match : " + method_name)
			sys.exit(-1)  #所有程序（方法，类等）停止，系统停止运行； sys.exit(0)正常退出
		return result

if __name__ == '__main__':
	xmlutil = XmlUtils()
	result = xmlutil.method_by_params(sys.argv)
	print(result)
