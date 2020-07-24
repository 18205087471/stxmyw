#!/bin/bash

function date2days {

    echo "$*" | awk '{

        z=int((14-$2)/12); y=$1+4800-z; m=$2+12*z-3;

        j=int((153*m+2)/5)+$3+y*365+int(y/4)-int(y/100)+int(y/400)-2472633;

        print j

    }'

}

db_user="root"

db_passwd="Great@1qaz2wsx"

db_defaults_file="/etc/my.cnf"

db_socket="/var/lib/mysql/mysql.sock"

db_backup="/data/mybak/"

db_backup_fulldir="/data/mybak/full/"

db_backup_incrementaldir="/data/mybak/incremental/"

db_backup_gzfull="/data/mybak/gzip/"

db_backup_tarfull="/data/myabak/tar.gzdb/"

rm_num=7

move_and_tar (){

if [ $# != 1 ]; then

       echo "参数不正确"

       exit 0 

fi

time_rm=`date -d "$1 days ago" +"back_%d-%m-%Y"`   

if [ $1 -eq 1 ]; then

        if [ -d ${db_backup_fulldir}${time_rm} ]; then

                tar -czPvf ${db_backup_tarfull}${time_rm}_full.tar.gz ${db_backup_fulldir}${time_rm}

                rm -rf ${db_backup_fulldir}${time_rm}

                echo "压缩目录rm $db_backup_fulldir${time_rm}" >>/backup/mysqldump/config/tar.log

        fi

fi

if [ $1 -gt 0 -a $a -lt 7 ]; then

        if [ -d $db_backup_incrementaldir${time_rm} ]; then

                tar -czPvf ${db_backup_tarfull}${time_rm}_increment.tar.gz ${db_backup_incrementaldir}${time_rm}

                rm -rf ${db_backup_incrementaldir}${time_rm}

                echo "压缩目录rm $db_backup_incrementaldir${time_rm}" >>/backup/mysqldump/config/tar.log

        fi

fi

}

time=$(date +"back_%d-%m-%Y")

source /data/mysqldump/config/config

_Day=$(date2days `echo ${backup_full:5:10}|awk 'BEGIN{FS="-"}{print $3,$2,$1}'`)

Day=$(date2days `date +"%Y %m %d"`)

echo $_Day

echo $Day

let result=$Day-$_Day

echo "相差$result天"

if [ -z ${backup_full} ] || [ $result -ge 7  ] ; then

echo '全备份'

backup_full=${time}

innobackupex --defaults-file=$db_defaults_file --no-timestamp --user=${db_user} --password=${db_passwd}  --socket=$db_socket ${db_backup_fulldir}${backup_full}/

    

if [ $? -eq 0 ]; then

        echo "${time} 备份成功!!!" >> /data/mysqldump/config/results.log

    else

        echo "${time} 备份失败???" >> /data/mysqldump/config/results.log

fi

echo "backup_full=${backup_full}" >/data/mysqldump/config/config

echo "backup_pre_name=full/${backup_full}" >>/data/mysqldump/config/config

while [ ${rm_num} -lt 8 -a ${rm_num} -gt 0 ]

do

move_and_tar ${rm_num}

rm_num=`expr ${rm_num} - 1`

done

echo '全备份'


fi
