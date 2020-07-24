#!/bin/bash
used=`free -m | awk 'NR==2' | awk '{print $3}'`
free=`free -m | awk 'NR==2' | awk '{print $4}'`
 
echo "===========================" >> /root/sfneicun.log
date >> /root/sfneicun.log
echo "Memory usage | [Use:${used}MB][Free:${free}MB]" >> /root/sfneicun.log
 
if [ $free -le 5500 ] ; then
  sync && echo 1 > /proc/sys/vm/drop_caches
  sync && echo 2 > /proc/sys/vm/drop_caches
  sync && echo 3 > /proc/sys/vm/drop_caches
  echo "10.0.18.184 sh has been successfully!"
  echo "OK" >> /var/spool/cron/delcache.log
else
  echo "10.0.18.184 sh did not successfully!"
  echo "Not required" >> /root/sfneicun.log
fi
