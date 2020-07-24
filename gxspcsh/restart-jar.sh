#!/bin/sh

NAME=$eureka-server
NAME=$task-center
NAME=$back-center
NAME=$api-gateway
NAME=$system-center
NAME=$log-center
NAME=$statistics-center
NAME=$supervise-center
NAME=$file-center
NAME=$work-center
NAME=$user-center
NAME=$auth-server
echo $NAME
ID=`ps -ef | grep "$NAME" | grep -v "$0" | grep -v "grep" | awk '{print $2}'`
echo $ID
echo "-------分割线--------"
for id in $ID
do
kill -9 $(ps -ef | grep -E 'back-center|task-center|eureka-server|api-gateway|system-center|log-center|statistics-center|supervise-center|file-center|work-center|user-center|auth-server' | grep -v grep | awk '{print$2}' > /dev/null)
echo "killed  $id"
done
sleep 15
cd /usr/local/java-jars
nohup java -jar eureka-server.jar >/dev/null 2>&1 &
nohup java -jar task-center.jar >/dev/null 2>&1 &
nohup java -jar back-center.jar >/dev/null 2>&1 &
nohup java -jar api-gateway.jar >/dev/null 2>&1 &
nohup java -jar auth-server.jar >/dev/null 2>&1 &
nohup java -jar file-center.jar >/dev/null 2>&1 &
nohup java -jar log-center.jar >/dev/null 2>&1 &
nohup java -jar statistics-center.jar >/dev/null 2>&1 &
nohup java -jar supervise-center.jar >/dev/null 2>&1 &
nohup java -jar system-center.jar >/dev/null 2>&1 &
nohup java -jar user-center.jar >/dev/null 2>&1 &
nohup java -jar work-center.jar >/dev/null 2>&1 &

