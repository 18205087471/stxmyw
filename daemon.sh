#!/bin/sh
#
#  Script:              send.sh
#  Instance:            1
#  version:            1

MUSTRUN1="auth-server"
MUSTRUN2="file-center"
MUSTRUN3="log-center"
MUSTRUN4="queue-center"
MUSTRUN5="statistics-center"
MUSTRUN6="supervise-center"
MUSTRUN7="system-center"
MUSTRUN8="user-center"
MUSTRUN9="work-center"


RUN=1

while [ -n $RUN ] 
do

	ps -ef | grep $MUSTRUN1 | grep -v grep
		if [ $? -eq 1 ]
		then
		nohup java -jar  /usr/20191018/auth-server.jar >/dev/null 2>&1 &
	 fi
	sleep 10
     
	ps -ef | grep $MUSTRUN2 | grep -v grep
       		 if [ $? -eq 1 ]
        		then
	 	nohup java -jar  /usr/20191018/file-center.jar >/dev/null 2>&1 &
	 fi	    

	ps -ef | grep $MUSTRUN3 | grep -v grep
		if [ $? -eq 1 ]
		then
         		
	  	nohup java -jar  /usr/20191018/log-center.jar >/dev/null 2>&1 &
     	 fi

	ps -ef | grep $MUSTRUN4 | grep -v grep
		if [ $? -eq 1 ]
	  	then
		
	  	nohup java -jar  /usr/20191018/queue-center.jar >/dev/null 2>&1 &
	fi
	 
	 ps -ef | grep $MUSTRUN5 | grep -v grep
		 if [ $? -eq 1 ]
	  	then
         		
	 	 nohup java -jar  /usr/20191018/statistics-center.jar >/dev/null 2>&1 &
         	 fi

       	ps -ef | grep $MUSTRUN6 | grep -v grep
		 if [ $? -eq 1 ]
	   	then
	   
	  	nohup java -jar  /usr/20191018/supervise-center.jar >/dev/null 2>&1 &
        	fi

	  ps -ef | grep $MUSTRUN7 | grep -v grep
	 	 if [ $? -eq 1  ]
	    	then
		
	  	nohup java -jar  /usr/20191018/system-center.jar >/dev/null 2>&1 &
	fi


	  ps -ef | grep $MUSTRUN8 | grep -v grep
	 	 if [ $? -eq 1  ]
	    	then
		
	  	nohup java -jar  /usr/20191018/user-center.jar >/dev/null 2>&1 &
	fi


	  ps -ef | grep $MUSTRUN9 | grep -v grep
	  	if [ $? -eq 1  ]
	    	then

		nohup java -jar /usr/20191018/work-center.jar >/dev/null 2>&1 &
	fi



     sleep 30
done
