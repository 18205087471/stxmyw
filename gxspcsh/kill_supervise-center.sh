#!/bin/bash
super="supervise-center"

super_PID=`jps |grep supervise|awk '{print $1}'`
#super_PID=`ps -ef|grep -v grep|grep supervise|awk '{print $2}'`

kill $super_PID
sleep 3
