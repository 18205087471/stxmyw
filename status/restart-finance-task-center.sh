#!/bin/bash
#activemq=路径
#使用说明，用来提示输入参数
usage() {
    echo "Usage: sh restart-finance-task-center.sh [start|stop|restart|status]"
    exit 1
}
 
#检查程序是否在运行
is_exist(){
  pid=`ps -ef|grep finance-task-center |grep -v grep|awk '{print $2}'|sed -n '3,16p'`
  #如果不存在返回1，存在返回0     
  if [ -z "${pid}" ]; then
   return 1
  else
    return 0
  fi
}
 
#启动方法
start(){
  is_exist
  if [ $? -eq 0 ]; then
    echo "finance-task-center is already running. pid=${pid}"
  else
    nohup java -jar -Xms6024m -Xmx6024m /usr/finance-task-center.jar >/dev/null 2>&1 &
  fi
}
 
#停止方法
stop(){
  is_exist
  if [ $? -eq "0" ]; then
    kill -9 $pid
  else
    echo "finance-task-center is not running"
  fi  
}
 
#输出运行状态
status(){
  is_exist
  if [ $? -eq "0" ]; then
    echo "finance-task-center is running. Pid is ${pid}"
  else
    echo "finance-task-center is NOT running."
  fi
}
 
#重启
restart(){
  stop
  sleep 5
  start
}
 
#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
  "start")
    start
    ;;
  "stop")
    stop
    ;;
  "status")
    status
    ;;
  "restart")
    restart
    ;;
  *)
    usage
    ;;
esac
