#!/bin/bash
#同步备份数据
IP=`cat /etc/sysconfig/network-scripts/ifcfg-e*|grep IPADDR=|awk -F = '{print $2}'|awk -F . '{print $4}'`
rsync -aSH --delete /data/mybak/full/ 10.0.18.245:/var/ftp/back_${IP}/
