#!/bin/bash
v_parameter=$1
v_order=$2
pssh -${v_parameter}  /home/hadoop/dhdp/conf/conf_ops/hosts  ${v_order}