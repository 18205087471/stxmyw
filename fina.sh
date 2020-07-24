#!/bin/bash
echo '###############start finance-task-center###############'

ansible fina -m shell -a 'killall java'
ansible fina -m shell -a 'nohup java -jar /usr/finance-task-center.jar >/dev/null 2>&1 &'
ansible fina -m shell -a 'ps -ef|grep java'

echo '--------over--------'
