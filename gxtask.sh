#!/bin/bash
time=`date`
echo -e "\033[1;36m######################################\033[0m"
echo -e "\033[1;36m#______| 开始更新 task-center |______#\033[0m"
echo -e "\033[1;36m######################################\033[0m"

ansible task -m shell -a 'killall java'
ansible task -m shell -a 'nohup java -jar /usr/task-center.jar >/dev/null 2>&1 &'
ansible task -m shell -a 'ps -ef|grep -v grep|grep java'

echo -e "\033[1;36m######################################\033[0m"
echo -e "\033[1;36m#______| task-center 更新完成 |______#\033[0m"
echo -e "\033[1;36m######################################\033[0m"
echo "${time} task-center更新成功!" >> /var/log/spc/task-center.log

ssh 10.0.18.222 "tailf -n 100 /logs/task-center/task-center-error.log"
