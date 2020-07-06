#!/bin/bash
time=`date`
echo -e "\033[1;36m##############################################\033[0m"
echo -e "\033[1;36m#______| 开始更新 finance-task-center |______#\033[0m"
echo -e "\033[1;36m##############################################\033[0m"
echo

ansible fina -m shell -a 'killall java'
ansible fina -m shell -a 'nohup java -jar /usr/finance-task-center.jar >/dev/null 2>&1 &'
ansible fina -m shell -a 'ps -ef|grep -v grep|grep java'

echo -e "\033[1;36m#############################################\033[0m"
echo -e "\033[1;36m#______| finance-task-center更新完成 |______#\033[0m"
echo -e "\033[1;36m#############################################\033[0m"
echo "${time} finance-task-center更新成功!" >> /var/log/spc/finance-task-center.log

ssh 10.0.18.183 "tailf -n 100 /logs/finance-task-center/finance-task-center-error.log"
