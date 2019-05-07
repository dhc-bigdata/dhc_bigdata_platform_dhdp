#!/bin/bash
while true
do
  /usr/sbin/ntpdate hadoop01 &> /dev/null
  sleep 300
done