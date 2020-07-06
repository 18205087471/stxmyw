#!/bin/bash
time=`date +"%m%d"`

for i in {auth-server,file-center,log-center,statistics-center,supervise-center,system-center,user-center,work-center,queue-center}
do
	mv /usr/java-jar/$i.jar /usr/java-jar/$i${time}.jar
done

oldj=`ls /usr/java-jar/*.jar|grep [0-9]`
rm -rf /usr/java-jar/$oldj

/root/spc/gxspc.sh

