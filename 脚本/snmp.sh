#!/bin/sh
printf '########################################\n'
printf '#               Welcome！              #\n'
printf '########################################\n'
#设置安装缓存并安装服务
sleep 2s
printf '\n'
printf '#####      MAKE CACHE AND INSTALL      #####\n'
printf '\n'
sleep 2s
yum makecache
if [ $? -eq 0 ]; 
then
	yum -y install net-snmp*
else
	printf '\n'
	echo "	/////*****   MISSION ERROR!   *****/////"
	printf '\n'
	echo "MAYBE SYSTEM MIRROR CANNOT BE LINKED,TRY CHECK IT AND TRY AGAIN!"
	exit 1
fi
sleep 2s
#定义程序变量
SNMP_IP=`cat /etc/sysconfig/network-scripts/ifcfg-e*|grep IPADDR=|awk -F = '{print $2}' `
OLD_SNMP_PUBLIC=`cat /etc/snmp/snmpd.conf | grep com2sec | awk -F = '{print $1}'`
printf '\n'
printf '######       OLD SNMP PUBLIC       ######\n'
sleep 1s
echo "$OLD_SNMP_PUBLIC"
printf '\n'
echo "///*********Change SNMP config*********///"
sleep 1s
#修改配置文件
sed -i "s/public/jsetec/g" /etc/snmp/snmpd.conf 
printf '\n'
echo "///******SNMP.CONF has been change******///"
NEW_SNMP_PUBLIC=`cat /etc/snmp/snmpd.conf | grep com2sec | awk -F = '{print $1}'`
sleep 1s
#启动服务
printf '\n'
echo "///*********Start SNMP.SERVICE*********///"
systemctl start snmpd.service
sleep 1s
printf '\n'
echo "///*********Enable SNMP.SERVICE*********///"
printf '\n'
systemctl enable snmpd.service
sleep 1s
#测试
printf '\n'
printf '########################################\n'
printf '#               Final Test             #\n'
printf '########################################\n'
printf '\n'
sleep 2s
SNMP_TEST=`snmpwalk -v 1 $SNMP_IP -c jsetec`
echo "$SNMP_TEST"
printf '\n'
sleep 2s
printf '###############    IP_ADDR    ############\n'
sleep 1s
echo "IP_ADDR=$SNMP_IP"
printf '\n'
sleep 1s
printf '#############    SNMP_PUBLIC    ##########\n'
sleep 1s
echo "$NEW_SNMP_PUBLIC"
printf '\n'
sleep 1s
printf '##########################################\n'
printf '#                                        #\n'
printf '#            Work ALL Finished!          #\n'
printf '#                                        #\n'
printf '##########################################\n'
