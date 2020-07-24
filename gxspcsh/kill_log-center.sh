#!/bin/bash
l="log-center"

l_PID=`jps|grep $l|awk '{print $1}'`

kill $l_PID
sleep 3
