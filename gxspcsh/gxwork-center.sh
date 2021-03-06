#!/bin/bash
#更换work-center脚本
clear
echo -e '\033[1;36m#####################################\033[0m'
echo -e "\033[1;36m#______| 开始更新work-center |______#\033[0m"
echo -e '\033[1;36m#####################################\033[0m'
echo
echo -e "\033[1;36m#______| 杀死177..179:work-center ......|______#\033[0m"
ansible auth1 -m script -a '/root/gxspcsh/kill_work-center.sh'
sleep 3
echo
ansible 10.0.18.177 -m shell -a 'for i in {178..179};do rsync -aSH /usr/java-jar/work-center.jar 10.0.18.$i:/usr/java-jar/work-center.jar;done'
echo
echo -e "\033[1;36m177..179 同步work-center完成!\033[0m"
echo
ansible auth1 -m shell -a '`nohup java -jar /usr/java-jar/work-center.jar >/dev/null 2>&1 &`'
echo
echo -e "\033[1;36m177..179 启动work-center完成!\033[0m"
echo
ansible auth1 -m shell -a 'jps;ps -ef|grep -v grep|grep work-center'
sleep 10
echo -e "\033[1;36m#______| 杀死180..182:work-center ......|______#\033[0m"
echo
ansible auth2 -m script -a '/root/gxspcsh/kill_work-center.sh'
sleep 3
echo
ansible 10.0.18.177 -m shell -a 'for i in {180..182};do rsync -aSH /usr/java-jar/work-center.jar 10.0.18.$i:/usr/java-jar/work-center.jar;done'
echo
echo -e "\033[1;36m180..182 同步work-center完成!\033[0m"
echo
ansible auth2 -m shell -a '`nohup java -jar /usr/java-jar/work-center.jar >/dev/null 2>&1 &`'
echo
echo -e "\033[1;36m180..182 启动work-center完成!\033[0m"
echo
ansible auth2 -m shell -a 'jps;ps -ef|grep -v grep|grep work-center'
sleep 10
echo
echo -e "\033[1;36m#______| 杀死243..244:work-center ......|______#\033[0m"
echo
ansible auth3 -m script -a '/root/gxspcsh/kill_work-center.sh'
sleep 3
echo
ansible 10.0.18.177 -m shell -a 'for i in {243..244};do rsync -aSH /usr/java-jar/work-center.jar 10.0.18.$i:/usr/java-jar/work-center.jar;done'
echo
echo -e "\033[1;36m243..244 同步work-center完成!\033[0m"
echo
ansible auth3 -m shell -a '`nohup java -jar /usr/java-jar/work-center.jar >/dev/null 2>&1 &`'
echo
echo -e "\033[1;36m243..244 启动work-center完成!\033[0m"
echo
ansible auth3 -m shell -a 'jps;ps -ef|grep -v grep|grep work-center'
echo
echo -e '\033[1;36m#####################################\033[0m'
echo -e "\033[1;36m#______| work-center更新完成 |______#\033[0m"
echo -e '\033[1;36m#####################################\033[0m'
