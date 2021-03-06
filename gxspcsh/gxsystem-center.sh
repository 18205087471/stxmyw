#!/bin/bash
#更换system-center脚本
clear
echo -e '\033[1;36m#######################################\033[0m'
echo -e "\033[1;36m#______| 开始更新system-center |______#\033[0m"
echo -e '\033[1;36m#######################################\033[0m'
echo
echo -e "\033[1;36m#______| 杀死177..179:system-center ......|______#\033[0m"
ansible auth1 -m script -a '/root/gxspcsh/kill_system-center.sh'
sleep 3
echo
ansible 10.0.18.177 -m shell -a 'for i in {178..179};do rsync -aSH /usr/java-jar/system-center.jar 10.0.18.$i:/usr/java-jar/system-center.jar;done'
echo
echo -e "\033[1;36m177..179 同步system-center完成!\033[0m"
echo
ansible auth1 -m shell -a '`nohup java -jar /usr/java-jar/system-center.jar >/dev/null 2>&1 &`'
echo
echo -e "\033[1;36m177..179 启动system-center完成!\033[0m"
echo
ansible auth1 -m shell -a 'jps;ps -ef|grep -v grep|grep system-center'
sleep 10
echo -e "\033[1;36m#______| 杀死180..182:system-center ......|______#\033[0m"
echo
ansible auth2 -m script -a '/root/gxspcsh/kill_system-center.sh'
sleep 3
echo
ansible 10.0.18.177 -m shell -a 'for i in {180..182};do rsync -aSH /usr/java-jar/system-center.jar 10.0.18.$i:/usr/java-jar/system-center.jar;done'
echo
echo -e "\033[1;36m180..182 同步system-center完成!\033[0m"
echo
ansible auth2 -m shell -a '`nohup java -jar /usr/java-jar/system-center.jar >/dev/null 2>&1 &`'
echo
echo -e "\033[1;36m180..182 启动system-center完成!\033[0m"
echo
ansible auth2 -m shell -a 'jps;ps -ef|grep -v grep|grep system-center'
sleep 10
echo
echo -e "\033[1;36m#______| 杀死243..244:system-center ......|______#\033[0m"
echo
ansible auth3 -m script -a '/root/gxspcsh/kill_system-center.sh'
sleep 3
echo
ansible 10.0.18.177 -m shell -a 'for i in {243..244};do rsync -aSH /usr/java-jar/system-center.jar 10.0.18.$i:/usr/java-jar/system-center.jar;done'
echo
echo -e "\033[1;36m243..244 同步system-center完成!\033[0m"
echo
ansible auth3 -m shell -a '`nohup java -jar /usr/java-jar/system-center.jar >/dev/null 2>&1 &`'
echo
echo -e "\033[1;36m243..244 启动system-center完成!\033[0m"
echo
ansible auth3 -m shell -a 'jps;ps -ef|grep -v grep|grep system-center'
echo
echo -e '\033[1;36m#######################################\033[0m'
echo -e "\033[1;36m#______| system-center更新完成 |______#\033[0m"
echo -e '\033[1;36m#######################################\033[0m'
