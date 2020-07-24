#!/bin/bash
#更换auth-server脚本
clear
echo -e '\033[1;36m#####################################\033[0m'
echo -e "\033[1;36m#______| 开始更新auth-server |______#\033[0m"
echo -e '\033[1;36m#####################################\033[0m'
echo
echo -e "\033[1;36m#______| 杀死177..179:auth-server ......|______#\033[0m"
ansible auth1 -m script -a '/root/gxspcsh/kill_auth-server.sh'
sleep 3
echo
ansible 10.0.18.177 -m shell -a 'for i in {178..179};do rsync -aSH /usr/java-jar/auth-server.jar 10.0.18.$i:/usr/java-jar/auth-server.jar;done'
echo
echo -e "\033[1;36m177..179 同步auth-server完成!\033[0m"
echo
ansible auth1 -m shell -a '`nohup java -jar /usr/java-jar/auth-server.jar >/dev/null 2>&1 &`'
echo
echo -e "\033[1;36m177..179 启动auth-server完成!\033[0m"
echo
ansible auth1 -m shell -a 'jps;ps -ef|grep -v grep|grep auth-server'
sleep 10
echo -e "\033[1;36m#______| 杀死180..182:auth-server ......|______#\033[0m"
echo
ansible auth2 -m script -a '/root/gxspcsh/kill_auth-server.sh'
sleep 3
echo
ansible 10.0.18.177 -m shell -a 'for i in {180..182};do rsync -aSH /usr/java-jar/auth-server.jar 10.0.18.$i:/usr/java-jar/auth-server.jar;done'
echo
echo -e "\033[1;36m180..182 同步auth-server完成!\033[0m"
echo
ansible auth2 -m shell -a '`nohup java -jar /usr/java-jar/auth-server.jar >/dev/null 2>&1 &`'
echo
echo -e "\033[1;36m180..182 启动auth-server完成!\033[0m"
echo
ansible auth2 -m shell -a 'jps;ps -ef|grep -v grep|grep auth-server'
sleep 10
echo
echo -e "\033[1;36m#______| 杀死243..244:auth-server ......|______#\033[0m"
echo
ansible auth3 -m script -a '/root/gxspcsh/kill_auth-server.sh'
sleep 3
echo
ansible 10.0.18.177 -m shell -a 'for i in {243..244};do rsync -aSH /usr/java-jar/auth-server.jar 10.0.18.$i:/usr/java-jar/auth-server.jar;done'
echo
echo -e "\033[1;36m243..244 同步auth-server完成!\033[0m"
echo
ansible auth3 -m shell -a '`nohup java -jar /usr/java-jar/auth-server.jar >/dev/null 2>&1 &`'
echo
echo -e "\033[1;36m243..244 启动auth-server完成!\033[0m"
echo
ansible auth3 -m shell -a 'jps;ps -ef|grep -v grep|grep auth-server'
echo
echo -e '\033[1;36m#####################################\033[0m'
echo -e "\033[1;36m#______| auth-server更新完成 |______#\033[0m"
echo -e '\033[1;36m#####################################\033[0m'
