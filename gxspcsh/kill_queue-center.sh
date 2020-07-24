#!/bin/bash
q="queue-center"

q_PID=`jps|grep $q|awk '{print $1}'`

kill $q_PID
sleep 3
