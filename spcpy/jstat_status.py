#!/usr/bin/python
  
import subprocess
import sys
import os
  
__maintainer__ = "Francis"
  
jps = '/data/jdk1.8/bin/jps'
jstat = '/data/jdk1.8/bin/jstat'
zabbix_sender = "/usr/bin/zabbix_sender"
zabbix_conf = "/usr/zabbix/etc/zabbix_agentd.conf"      
send_to_zabbix = 1
ip=os.popen("ifconfig|grep 'inet '|grep -v '127.0'|xargs|awk -F '[ :]' '{print $3}'").readline().rstrip()
serverip="10.0.18.177"
  
#"{#JAVA_NAME}":"tomcat_web_1"
  
  
def usage():
    """Display program usage"""
  
    print "\nUsage : ", sys.argv[0], " java_name alive|all"
    print "Modes : \n\talive : Return pid of running processs\n\tall : Send jstat stats as well"
    sys.exit(1)
  
  
class Jprocess:
  
    def __init__(self, arg):
        self.pdict = {
        "jpname": arg,
        }
  
        self.zdict = {
        "Heap_used" : 0,
                "Heap_ratio" : 0,
        "Heap_max" : 0,
        "Perm_used" : 0,
                "Perm_ratio" : 0,
        "Perm_max"  : 0,
                "S0_used"   : 0,
                "S0_ratio"  : 0,
                "S0_max"    : 0,
                "S1_used"   : 0,
                "S1_ratio"  : 0,
                "S1_max"    : 0,
                "Eden_used" : 0,
                "Eden_ratio" : 0,
                "Eden_max"  : 0,
                "Old_used"  : 0,
                "Old_ratio" : 0,
                "Old_max"   : 0,
                "YGC"       : 0,
                "YGCT"      : 0,
                "YGCT_avg"      : 0,
                "FGC"       : 0,
                "FGCT"      : 0,
                "FGCT_avg"      : 0,
                "GCT"       : 0,
                "GCT_avg"       : 0,
                  
        }
  
  
    def chk_proc(self):
#  ps -ef|grep java|grep tomcat_web_1|awk '{print $2}'
#                print self.pdict['jpname']
                pidarg = '''ps -ef|grep java|grep %s|grep -v grep | grep -v jstat_status.py |awk '{print $2}' ''' %(self.pdict['jpname']) 
                #pidout = subprocess.Popen(pidarg,shell=True,stdout=subprocess.PIPE) 
                #pid = pidout.stdout.readline().strip('\n') 
                pid = subprocess.check_output(pidarg, shell=True).strip()
                if pid != "" :
                   self.pdict['pid'] = pid
#                   print "Process found :", java_name, "with pid :", self.pdict['pid']
                else:
                   self.pdict['pid'] = ""
#                   print "Process not found"
                return self.pdict['pid']
  
    def get_jstats(self):
        if self.pdict['pid'] == "":
            return False
        self.pdict.update(self.fill_jstats("-gc"))
        self.pdict.update(self.fill_jstats("-gccapacity"))
        self.pdict.update(self.fill_jstats("-gcutil"))
  
#        print "\nDumping collected stat dictionary\n-----\n", self.pdict, "\n-----\n"
  
    def fill_jstats(self, opts):
#        print "\nGetting", opts, "stats for process", self.pdict['pid'], "with command : sudo", jstat, opts, self.pdict['pid'] ,"\n"
#        jstatout = subprocess.Popen(['sudo','-u','tomcat', jstat, opts, self.pdict['pid']], stdout=subprocess.PIPE)
        #print([jstat, opts, self.pdict['pid']])
        jstatout = subprocess.Popen([jstat, opts, self.pdict['pid']], stdout=subprocess.PIPE)
        stdout, stderr = jstatout.communicate()
        legend, data = stdout.split('\n',1)
        mydict = dict(zip(legend.split(), data.split()))
        return mydict
  
    def compute_jstats(self):
        if self.pdict['pid'] == "":
            return False
        self.zdict['S0_used'] = format(float(self.pdict['S0U']) * 1024,'0.2f')
        self.zdict['S0_max'] =  format(float(self.pdict['S0C']) * 1024,'0.2f')
        self.zdict['S0_ratio'] = format(float(self.pdict['S0']),'0.2f')
 
        self.zdict['S1_used'] = format(float(self.pdict['S1U']) * 1024,'0.2f')
        self.zdict['S1_max'] = format(float(self.pdict['S1C']) * 1024,'0.2f')
        self.zdict['S1_ratio'] = format(float(self.pdict['S1']),'0.2f')
  
        self.zdict['Old_used'] = format(float(self.pdict['OU']) * 1024,'0.2f')
        self.zdict['Old_max'] =  format(float(self.pdict['OC']) * 1024,'0.2f')
        self.zdict['Old_ratio'] = format(float(self.pdict['O']),'0.2f')
 
        self.zdict['Eden_used'] = format(float(self.pdict['EU']) * 1024,'0.2f')
        self.zdict['Eden_max'] = format(float(self.pdict['EC']) * 1024,'0.2f')
        self.zdict['Eden_ratio'] = format(float(self.pdict['E']),'0.2f')            
# self.zdict['Perm_used'] = format(float(self.pdict['PU']) * 1024,'0.2f')
# self.zdict['Perm_max'] = format(float(self.pdict['PC']) * 1024,'0.2f')
# self.zdict['Perm_ratio'] = format(float(self.pdict['P']),'0.2f')
                 
        self.zdict['Heap_used'] = format((float(self.pdict['EU']) + float(self.pdict['S0U']) + float(self.pdict['S1U'])  + float(self.pdict['OU'])) * 1024,'0.2f')
        self.zdict['Heap_max'] = format((float(self.pdict['EC']) + float(self.pdict['S0C']) + float(self.pdict['S1C'])  + float(self.pdict['OC'])) * 1024,'0.2f')
        self.zdict['Heap_ratio'] = format(float(self.zdict['Heap_used']) / float(self.zdict['Heap_max'])*100,'0.2f')
 
        self.zdict['YGC'] = self.pdict['YGC']
        self.zdict['FGC'] = self.pdict['FGC']
        self.zdict['YGCT'] = format(float(self.pdict['YGCT']),'0.3f')
        self.zdict['FGCT'] = format(float(self.pdict['FGCT']),'0.3f')
        self.zdict['GCT'] = format(float(self.pdict['GCT']),'0.3f') 
     
        if self.pdict['YGC'] == '0':
           self.zdict['YGCT_avg'] = '0'
        else: 
           self.zdict['YGCT_avg'] = format(float(self.pdict['YGCT'])/float(self.pdict['YGC']),'0.3f')
        if self.pdict['FGC'] == '0':
           self.zdict['FGCT_avg'] = '0'
        else:
           self.zdict['FGCT_avg'] = format(float(self.pdict['FGCT'])/float(self.pdict['FGC']),'0.3f')
        if self.pdict['YGC'] == '0' and self.pdict['FGC'] == '0':
           self.zdict['GCT_avg'] = '0' 
        else:
           self.zdict['GCT_avg'] = format(float(self.pdict['GCT'])/(float(self.pdict['YGC']) + float(self.pdict['FGC'])),'0.3f') 
                   
  
       # print "Dumping zabbix stat dictionary\n-----\n", self.zdict, "\n-----\n"
  
    def send_to_zabbix(self, metric):
####      {#JAVA_NAME} tomcat_web_1 
####      UserParameter=java.discovery,/usr/bin/python /opt/app/zabbix/sbin/java_discovery.py
####      UserParameter=java.discovery_status[*],/opt/app/zabbix/sbin/jstat_status.sh $1 $2 $3 $4 
####      java.discovery_status[tomcat_web_1,Perm_used]
####      java.discovery_status[{#JAVA_NAME},Perm_used]
        key = "java.discovery_status[" + self.pdict['jpname'] + "," + metric + "]"
  
        if self.pdict['pid'] != "" and  send_to_zabbix > 0:
           #print key + ":" + str(self.zdict[metric])
           try:
                                       
                 subprocess.call([zabbix_sender, "-c", zabbix_conf, "-k", key, "-o", str(self.zdict[metric])], stdout=FNULL,stderr=FNULL, shell=False) 
           except OSError, detail:
                 print "Something went wrong while exectuting zabbix_sender : ", detail
        else:
           print "Simulation: the following command would be execucted :\n", zabbix_sender, "-c", zabbix_conf, "-k", key, "-o", self.zdict[metric], "\n"
  
  
accepted_modes = ['alive', 'all']
  
 
if len(sys.argv) == 3 and sys.argv[2] in accepted_modes:
    java_name = sys.argv[1]
    mode = sys.argv[2]
else:
    usage()

#Check if process is running / Get PID
jproc = Jprocess(java_name) 
pid = jproc.chk_proc()
  
  
if pid != "" and  mode == 'all':
   jproc.get_jstats()
   #print jproc.zdict
   jproc.compute_jstats()               
   FNULL = open(os.devnull, 'w')
   for key in jproc.zdict:
       #print key,jproc.zdict[key]
       jproc.send_to_zabbix(key)
   FNULL.close()
  # print pid
 
  
else:
   print 0
