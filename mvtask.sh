#!/bin/bash
time=`date +"%m%d"`
mv /usr/task-center.jar /usr/task-center${time}.jar

ls /usr/*.jar|grep [0-9]|rm -rf 

/root/spc/gxtask.sh

