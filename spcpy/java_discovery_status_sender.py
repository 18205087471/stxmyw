#/usr/bin/python
#This script is used to discovery disk on the server
import subprocess
import os
import socket
import json
import glob
    
java_names_file='java_names.txt'
javas=[]
if os.path.isfile(java_names_file):
  
   args='''awk -F':' '{print $1':'$2}' %s'''  % (java_names_file)
   t=subprocess.Popen(args,shell=True,stdout=subprocess.PIPE).communicate()[0]
elif glob.glob('/usr/java-jar/*.jar'): 
  t=subprocess.Popen('cd /usr/java-jar && ls *.jar|grep jar',shell=True,stdout=subprocess.PIPE)
  res=subprocess.check_output('cd /usr/java-jar && ls *.jar|grep jar',stderr=subprocess.STDOUT,shell = True)
 
for java in t.stdout.readlines():
    if len(java) != 0:
       javas.append({'{#JAVA_NAME}':java.strip('\n').strip(':')})
#print json.dumps({'data':javas},indent=4,separators=(',',':'))
 
#print res
 
for java in res.strip().split("\n"):
    if java:
        #print java
        out = subprocess.check_output("python /usr/zabbix/etc/scripts/java/jstat_status.py %s all" % java, shell=True)
        #print(out)
