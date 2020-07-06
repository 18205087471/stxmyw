#!/bin/bash
time=`date`
clear
echo -e "\033[1;32m###############################\033[0m"
echo -e "\033[1;32m#_______| 开始更新网关 |______#\033[0m"
echo -e "\033[1;32m###############################\033[0m"
echo
ansible api1 -m script -a '/root/spc/kill_api.sh'
sleep 3
echo -e "\033[9;31m1.___________|网关1已杀死!|__________\033[0m"

ansible 10.0.18.165 -m shell -a 'for i in {166..170};do rsync -aSH /usr/api-gateway.jar 10.0.18.$i:/usr/api-gateway.jar;done'

ansible api1 -m shell -a '`nohup java -jar /usr/api-gateway.jar >/dev/null 2>&1 &`'

ansible api1 -m shell -a 'jps;ps -ef|grep -v grep|grep api-gateway'

sleep 10

ansible api2 -m script -a '/root/spc/kill_api.sh'
sleep 3
echo -e "\033[9;31m1.___________|网关2已杀死!|__________\033[0m"

ansible 10.0.18.165 -m shell -a 'for i in {171..176};do rsync -aSH /usr/api-gateway.jar 10.0.18.$i:/usr/api-gateway.jar;done'

ansible api2 -m shell -a '`nohup java -jar /usr/api-gateway.jar >/dev/null 2>&1 &`'

ansible api2 -m shell -a 'jps;ps -ef|grep -v grep|grep api-gateway'

echo -e "\033[1;32m###############################\033[0m"
echo -e "\033[1;32m#_______| 网关启动完成 |______#\033[0m"
echo -e "\033[1;32m###############################\033[0m"
echo "${time} 网关更新成功!" >> /var/log/spc/api-gateway.log
