#!/bin/bash
#mysql自动备份并压缩脚本
#定义环境变量

db_user="root"

db_passwd="XXXXXXXXXXXX"

db_defaults_file="/etc/my.cnf"

db_socket="/var/lib/mysql/mysql.sock"

db_data="/data/mybak/"

db_data_fulldir="/data/mybak/full/"


time=`date +"back_%d-%m-%Y"`

time_rm=`date -d "$1 days ago" +"back_%d-%m-%Y"`

source /data/mybak/config/config 	//加载配置文件变量

if [ -z ${backup_full} ]; then

backup_full=${time}

innobackupex --defaults-file=$db_defaults_file --no-timestamp --user=${db_user} --password=${db_passwd}  --socket=$db_socket ${db_data_fulldir}${backup_full}/

	if [ $? -eq 0 ]; then

        echo "${time} 备份成功!!!" >> /data/mybak/config/results.log

	else

        echo "${time} 备份失败???" >> /data/mybak/config/results.log

	fi

echo "backup_full=${backup_full}" >/data/mybak/config/config

echo "backup_pre_name=full/${backup_full}" >>/data/mybak/config/config

fi

if [ -d ${db_data_fulldir}${time_rm} ]; then

		tar -czPf ${db_data_fulldir}${time}.tar.gz ${db_data_fulldir}${time}

		rm -rf ${db_data_fulldir}${time_rm} 	//删除前一天的备份

		echo "压缩目录rm $db_data_fulldir${time_rm}" >>/data/mybak/config/tar.log

fi

IP=`cat /etc/sysconfig/network-scripts/ifcfg-e*|grep IPADDR=|awk -F = '{print $2}'|awk -F . '{print $4}'`

rsync -aSH /data/mybak/full/*.tar.gz IP:/var/ftp/back_${IP}/

echo '压缩目录 /data/mybak/full/${time} 成功!!!' >>/data/mysqldump/config/tar.log