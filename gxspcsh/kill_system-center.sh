#!/bin/bash
system="system-center"

system_PID=`jps|grep $system|awk '{print $1}'`

kill $system_PID
sleep 3
