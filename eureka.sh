#!/bin/bash
#注册中心守护脚本
time=`date`
ss -utnalp|grep :1111 >/dev/null
if [ $? -eq 0 ];then
        exit
else
        nohup java -jar /usr/eureka-server.jar >/dev/null 2>&1 &
        printf "###########################\n"
        printf "#      eureka重启成功     #\n"
        printf "###########################\n"
        echo '${time} eureka重启成功' >> /var/log/jar.log
fi