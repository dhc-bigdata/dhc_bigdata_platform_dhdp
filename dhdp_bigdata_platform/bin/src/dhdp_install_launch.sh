#!/bin/bash
 dhdp_dir=/home/hadoop/dhdp/bin/

cd $dhdp_dir && bash dhdp_each_host_init.sh

cd $dhdp_dir && bash dhdp_each_host_init_resource.sh

cd $dhdp_dir && bash dhdp_each_host_install_tools.sh