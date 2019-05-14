#!/bin/bash

##主目录
v_parameter=$1
##需上传至目录
v_order=$2
pscp -h /home/hadoop/dhdp/conf/conf_ops/hosts ${v_parameter} ${v_order}