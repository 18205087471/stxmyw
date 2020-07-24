#! /bin/bash
mycat=`/usr/local/mycat/bin/mycat status | cut -d "(" -f2 | cut -d ")" -f1`
if [ "$mycat" == "3936" ]
	then
		echo "mycat is running!"
	else
		echo "mycat not running!"
fi

keepalived=`systemctl status keepalived | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1 `
if [ "$keepalived" == "running" ]
	then
		echo "keepalived is running!"
	else
		echo "keepalived not running!"
fi
