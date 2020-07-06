#!/bin/bash
time=`date +"%m%d"`
mv /usr/finance-task-center.jar /usr/finance-task-center${time}.jar

ls /usr/*.jar|grep [0-9]|rm -rf 

/root/spc/gxfina.sh

