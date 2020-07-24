#!/bin/bash
path="/data/mybak/full/"
rmf=`ls -rt $path|sed -n '1,4p'`

for i in $rmf
do
	rm -rf $path$i
done

IP=`cat /etc/sysconfig/network-scripts/ifcfg-e*|grep IPADDR=|awk -F = '{print $2}'|awk -F . '{print $4}'`

rsync -aSH --delete /data/mybak/full/ 10.0.18.245:/var/ftp/back_${IP}/
