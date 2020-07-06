#!/bin/bash
time=`date +"%m%d"`
mv /usr/api-gateawy.jar /usr/api-gateway${time}.jar

ls /usr/*.jar|grep [0-9]|rm -rf 

if [  ];then
/root/spc/gxapi.sh

