#!/bin/bash

ansible back1,back2 -m shell -a '`nohup java -jar /usr/$i.jar >/dev/null 2>&1 &`'

ansible api1,api2 -m shell -a '`nohup java -jar /usr/api-gateway.jar >/dev/null 2>&1 &`'

ansible auth1,auth2,auth3 -m shell -a 'for i in {auth-server,file-center,log-center,statistics-center,supervise-center,system-center,user-center,work-center,queue-center};do `nohup java -jar /usr/java-jar/$i.jar >/dev/null 2>&1 &` sleep 0.5;done'

ansible fina -m shell -a 'nohup java -jar /usr/finance-task-center.jar >/dev/null 2>&1 &'

ansible redis -m shell -a '/usr/local/bin/redis-server /etc/redis/6379.conf'

ansible redis -m shell -a '/usr/local/bin/redis-sentinel /etc/redis/sentinel.conf'

ansible logmycat -m shell -a '/usr/local/mycat/bin/mycat restart'

ansible mycat -m shell -a '/usr/local/mycat/bin/mycat restart'

ansible activemq -m shell -a '/usr/apache-activemq-5.10.0/bin/activemq start'

ansible task -m shell -a 'nohup java -jar /usr/task-center.jar >/dev/null 2>&1 &'


