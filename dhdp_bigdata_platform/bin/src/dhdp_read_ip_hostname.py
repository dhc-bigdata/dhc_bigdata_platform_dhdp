#!/usr/bin/python
#coding=utf-8
from xml.dom.minidom import parse
import xml.dom.minidom
def read_xml_ip_hostname():
    docxml = xml.dom.minidom.parse("/home/hadoop/conf/xml/hlk_hosts.xml")  #加载xml文件 路径需要改动
    root = docxml.documentElement  # 获取元素的根节点
    hosts = root.getElementsByTagName('host')  #获取子节点数组
    #对所有的子节点进行遍历
    for host in hosts:
        IP = host.getElementsByTagName("IP")[0]
        hostname = host.getElementsByTagName("hostname")[0]
        IPList = IP.childNodes[0].data
        hostNameList =hostname.childNodes[0].data
        print(IPList+" "+hostNameList)
if __name__ == '__main__':
    read_xml_ip_hostname()
