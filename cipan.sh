#!/bin/bash
#
DEV=`df -hP | grep '^/dev/*' | cut -d' ' -f1 | sort`
for I in $DEV
do dev=`df -Ph | grep $I | awk '{print $1}'`
size=`df -Ph | grep $I | awk '{print $2}'`
used=`df -Ph | grep $I | awk '{print $3}'`
free=`df -Ph | grep $I | awk '{print $4}'`
rate=`df -Ph | grep $I | awk '{print $5}'`
mount=`df -Ph | grep $I | awk '{print $6}'`
echo -e "$I:\tsize:$size\tused:$used\tfree:$free\trate:$rate\tmount:$mount"
F=`echo $rate | awk -F% '{print $1}'`
if [ $F -ge 80 ];then
    echo "$mount Warn"
    else 
    echo "It's OK"
fi
done

