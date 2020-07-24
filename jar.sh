#!/bin/bash
#定义jar包名
#jar_NAME=read -p "请输入jar包名:"
jar_NAME="work-center"

clear
echo -e "\033[1;36m-----------------------------------------\033[0m"
echo -e "\e[1;34m|            开始换$jar_NAME包           |\e[0m"
echo -e "\033[1;36m-----------------------------------------\033[0m"

ansible 10.0.18.177 -m shell -a 'for i in {178..182};do rsync -aSH /usr/java-jar/${jar_NAME}.jar 10.0.18.$i:/usr/java-jar/$jar_NAME.jar;done'
ansible 10.0.18.177 -m shell -a 'for i in {243..244};do rsync -aSH /usr/java-jar/${jar_NAME}.jar 10.0.18.$i:/usr/java-jar/$jar_NAME.jar;done'

#jar_Id=`ansible auth1 -m shell -a 'ps -ef|grep -v grep|grep $jar_NAME'|awk '{print $2}'|sed -n '/[0-9]/p'`

for i in {177..179}
do
	PID=`ssh 10.0.18.$i "ps -ef|grep -v grep|grep $jar_NAME"|awk '{print $2}'`
	ssh 10.0.18.$i "kill -9 $PID"
	ssh 10.0.18.$i "`nohup java -jar /usr/java-jar/${jar_NAME}.jar >/dev/null 2>&1 &`"
	exit
done

for i in {180..182}
do
	PID=`ssh 10.0.18.$i "ps -ef|grep -v grep|grep $jar_NAME"|awk '{print $2}'`
	ssh 10.0.18.$i "kill -9 $PID"
	ssh 10.0.18.$i "`nohup java -jar /usr/java-jar/${jar_NAME}.jar >/dev/null 2>&1 &`"
	exit
done

for i in {243..244}
do
	PID=`ssh 10.0.18.$i "ps -ef|grep -v grep|grep $jar_NAME"|awk '{print $2}'`
	ssh 10.0.18.$i "kill -9 $PID"
	ssh 10.0.18.$i "`nohup java -jar /usr/java-jar/${jar_NAME}.jar >/dev/null 2>&1 &`"
	exit
done



printf "\e[1;44m%s\n\e[0m" "-----------------------------"
printf "\e[1;44m%s\e[0m\n" "|          任务完成         |"
printf "\e[1;44m%s\n\e[0m" "-----------------------------"
