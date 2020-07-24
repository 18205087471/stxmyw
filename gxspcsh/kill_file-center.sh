#!/bin/bash
f="file-center"

f_PID=`jps|grep $f|awk '{print $1}'`

kill $f_PID
sleep 3
