#!/bin/bash
u="user-center"

u_PID=`jps|grep $u|awk '{print $1}'`

kill $u_PID
sleep 3
