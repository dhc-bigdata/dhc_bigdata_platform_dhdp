#!/bin/bash

v_order=$1
log_dir=/var/log/pssh/pssh
pssh -e $log_dir  -h /home/hadoop/dhdp/conf/conf_ops/hosts  ${v_order}
