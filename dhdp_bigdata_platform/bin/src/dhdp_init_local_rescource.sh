#!/bin/bash

dhdp_data_dir=/home/hadoop/dhdp/data #数据目录
dhdp_log_dir=/home/hadoop/dhdp/logs #集群存放日志


rm -rf $dhdp_data_dir/*
rm -rf $dhdp_log_dir/*

#创建日志目录
mkdir -p $dhdp_log_dir/hadoop
mkdir -p $dhdp_log_dir/yarn
mkdir -p $dhdp_log_dir/zookeeper
mkdir -p $dhdp_log_dir/hbase
mkdir -p $dhdp_log_dir/kafka
mkdir -p $dhdp_log_dir/hive
mkdir -p $dhdp_log_dir/spark
#创建数据目录
mkdir -p $dhdp_data_dir/hadoop
mkdir -p $dhdp_data_dir/yarn
mkdir -p $dhdp_data_dir/zookeeper
mkdir -p $dhdp_data_dir/hbase
mkdir -p $dhdp_data_dir/kafka
mkdir -p $dhdp_data_dir/hive
mkdir -p $dhdp_data_dir/spark



















