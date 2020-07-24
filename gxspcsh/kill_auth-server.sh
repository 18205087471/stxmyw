#!/bin/bash
a="auth-server"

a_PID=`jps |grep $a|awk '{print $1}'`

kill $a_PID

sleep 3
