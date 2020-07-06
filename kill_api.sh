#!/bin/bash
api="api-gateway"

api_PID=`jps|grep $api|awk '{print $1}'`

for i in $api_PID
do
	kill -9 $i
done

sleep 3
