#!/bin/bash
sta="statistics-center"

sta_PID=`jps|grep $sta|awk '{print $1}'`

kill $sta_PID
sleep 3
