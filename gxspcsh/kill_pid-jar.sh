#!/bin/bash
jpid=`jps|grep -v grep|grep -v Jps|awk '{print $1}'`

for pid in $jpid
do
      kill -9 $pid
done
sleep 3
