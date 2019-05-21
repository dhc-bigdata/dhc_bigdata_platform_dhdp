#!/usr/bin/python
#coding=utf-8
from xml.dom.minidom import parse
import xml.dom.minidom
def read_xml_hostname():
    docxml = xml.dom.minidom.parse("/home/hadoop/dhdp/conf/conf_ops/dhdp_hosts.xml")  #加载xml文件 路径需要改动
    root = docxml.documentElement  # 获取元素的根节点
    hosts = root.getElementsByTagName('host')  #获取子节点数组
    hostNameList = []
    for host in hosts:
        hostname = host.getElementsByTagName("hostname")[0]
        hostNameList.append(hostname.childNodes[0].data)
    del hostNameList[0]
    for i in hostNameList:
        print(i)
if __name__ == '__main__':
    read_xml_hostname()