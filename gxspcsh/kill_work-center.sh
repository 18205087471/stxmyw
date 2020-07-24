#!/bin/bash
w="work-center"

w_PID=`jps|grep $w|awk '{print $1}'`

kill -15 $w_PID

sleep 6
