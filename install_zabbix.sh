#!/bin/bash
#Data:2019-11-28
#Version:1.0
#Author:Sunny_RM(1275757008@qq.com)
#The software list:Nginx,MySQL,PHP,Zabbix for php,Java.
#This script can automatically install all software on your machine.
#For RHEL7 version

#定义颜色
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;34m"
SETCOLOR_NORMAL="echo -e \\033[0;39m"

#定义数据库相关变量.
MYSQL_USER=root
MYSQL_PASS=Great@1qaz2wsx
MYSQL_PORT=3306
MYSQL_HOST=localhost
MYSQL_CMD="mysql -u$MYSQL_USER -p$MYSQL_PASS -p$MYSQL_PORT -h$MYSQL_HOST"
MYSQL_ADMIN="mysqladmin -u$MYSQL_USER -p$MYSQL_PASS -P$MYSQL_PORT -h$MYSQL_HOST"
MYSQL_COMM="mysql -u$MYSQL_USER -p$MYSQL_PASS -P$MYSQL_PORT -h$MYSQL_HOST -e"
#Define default variables, you can modify the value.
nginx_version=nginx-1.16.1
mysql_version=mysql-5.7.27-1.el7.x86_64.rpm-bundle.tar
zabbix_version=zabbix-4.2.7
format1=.tar.gz
format2=.tgz

#Determine the language environment
language(){
	echo $LANG |grep -q zh
	if [ $? -eq 0 ];then
		return 0
	else
		return 1
	fi
}
#Define a user portal menu.

menu(){
	clear
	language
	if [ $? -eq 0 ];then
		echo "  ##############----Menu----##############"
		echo "# 1. 安装Nginx"
		echo "# 2. 安装Mysql"
		echo "# 3. 安装PHP"
		echo "# 4. 安装Zabbix_server"
		echo "# 5. 安装zabbix_agent"
		echo "# 6. 退出程序"
		echo "  ########################################"
	else
		echo "  ##############----Menu----##############"
		echo "# 1. Install Nginx"
		echo "# 2. Install Mysql"
		echo "# 3. Install PHP"
		echo "# 4. Install zabbix_server"
		echo "# 5. Install zabbix_agent"
		echo "# 6. Exit Program"
		echo "  ########################################"
	fi
}

#Read user's choice
choice(){
	language
	if [ $? -eq 0 ];then
		read -p "请选择一个菜单[1-6]:" select
	else
		read -p "Please choice a menu[1-6]:" select
	fi
}

#关闭防火墙和SELINUX
systemctl stop firewalld
setenforce 0

#生成Yum源文件
yum_repo(){
	cat >> /etc/yum.repos.d/local.repo <<- EOF
	[repodata]
	name=localrepo
	baseurl=ftp://10.0.18.164/centos
	enabled=1
	gpgcheck=0

	[everythingrepo]
	name=localrepo
	baseurl=ftp://10.0.18.164/localrepo
	enabled=1
	gpgcheck=0
EOF
}

#检测yum源
num=$(yum repolist -e 0 | awk '/repolist/{print $2}' | sed 's/,//')

    if [ $num -le 0 ];then
        $SETCOLOR_FAILURE
        echo -n "[ERROR]:没有YUM源!"
		$SETCOLOR_NORMAL
		rm -rf /etc/yum.repos.d/C*
		yum_repo
    fi

install_php(){
	yum -y install php php-fpm php-mysql php-gd php-ldap php-xml php-bamath php-mbstring
}

install_mysql(){
	tar xf $mysql_version
	yum -y install mysql-c*
	systemctl start mysqld
	cat /var/log/mysqld.log |grep passw
}

#date.timezone = Asia/Shanghai
#max_execution_time = 300
#post_max_size = 32M
#max_input_time = 300
#memory_limit = 128M

#修改nginx配置文件
nginx_confP="/usr/local/nginx/conf/nginx.conf"
nginx_conf(){
	sed -i '65,71s/#//' $nginx_confP
	sed -i '69s/^\ /#/' $nginx_confP
	sed -i '70s/_params/.conf/' $nginx_confP
	#sed -i '33a\   fastcgi_buffers 8 16k;' $nginx_confP
	#sed -i '34a\   fastcgi_buffer_size 32k;' $nginx_confP
	#sed -i '35a\   fastcgi_connect_timeout 300;' $nginx_confP
	#sed -i '36a\   fastcgi_send_timeout 300;' $nginx_confP
	#sed -i '37a\   fastcgi_read_timeout 300;' $nginx_confP
}

#fastcgi_buffers 8 16k;
#fastcgi_buffer_size 32k;
#fastcgi_connect_timeout 300;
#fastcgi_send_timeout 300;
#fastcgi_read_timeout 300;

E_PATH(){
	echo PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/usr/zabbix/bin:/usr/zabbix/sbin" >> /etc/profile
}

install_zabbix_server(){
	yum -y install gcc pcre-devel openssl-devel zlib-devel

	yum -y install mysql-devel net-snmp-devel curl-devel libvirt java-1.8.0-openjdk-devel libevent-devel libxml2-devel

	sed -i 's!;date.timezone =!date.timezone = Asia/Shanghai!' /etc/php.ini
	sed -i 's!max_execution_time = 30!max_execution_time = 300!' /etc/php.ini
	sed -i 's!post_max_size = 8M!post_max_size = 32M!' /etc/php.ini
	sed -i 's!max_input_time = 60!max_input_time = 300!' /etc/php.ini
	
	cd $zabbix_version/frontends/

	cp -r php/* /usr/local/nginx/html/

	chmod -R 777 /usr/local/nginx/html/*
	
	nginx_conf
	
	/usr/local/nginx/sbin/nginx
	
	$MYSQL_COMM 'create database zabbix character set utf8'
	$MYSQL_COMM "grant all on zabbix.* to zabbix@'localhost' identified by 'Great@1qaz2wsx'"

	cd $zabbix/database/mysql/

	$MYSQL_CMD zabbix < schema.sql
	$MYSQL_CMD zabbix < images.sql
	$MYSQL_CMD zabbix < data.sql
	
	useradd -s /sbin/nologin zabbix
	
	cd ..
	
	./configure --enable-proxy --enable-server --enable-agent --with-mysql=/etc/my.cnf --with-net-snmp --with-libcurl --with-java

	make install
	
	E_PATH
}


#ListenPort=10051
#LogFile=/tmp/zabbix_server.log
#DBHost=localhost
#DBName=zabbix
#DBUser=zabbix
#DBPassword=Great@1qaz2wsx
#DBPort=3306
#ListenIP=0.0.0.0

#修改zabbix_server配置文件
zabbix_server_conf="/usr/zabbix/etc/zabbix_server.conf"
zabbix_server(){
	sed -i 's/.*DBHost=localhost/DBHost=localhost/' $zabbix_server_conf
	sed -i 's/.*DBUser=zabbix/DBUser=zabbix/' $zabbix_server_conf
	sed -i 's/.*DBPassword=/DBPassword=Great@1qaz2wsx/' $zabbix_server_conf
	sed -i 's/.*DBPort=/DBPort=3306/' $zabbix_server_conf
	sed -i 's/.*ListenIP=0.0.0.0/ListenIP=0.0.0.0/' $zabbix_server_conf
}

#Server=127.0.0.1,10.0.18.0
#ServerActive=127.0.0.1,10.0.18.0
#Hostname=zabbixclient_web1
#EnableRemoteCommands=1	//监控异常后，是否允许服务器远程过来执行命令，如重启某个服务
#UnsafeUserParameters=1

zabbix_IP=`cat /etc/sysconfig/network-scripts/ifcfg-e*|grep IPADDR=|awk -F = '{print $2}'|awk -F . '{print $4}'`

#修改zabbix_agent配置文件配置文件
zabbix_agentd_conf="/usr/zabbix/etc/zabbix_agentd.conf"
zabbix_agent_C(){
	sed -i 's/.*StartAgents=3/StartAgents=0/' $zabbix_agentd_conf
	sed -i 's/.*ServerActive=127.0.0.1$/ServerActive=10.0.18.245/' $zabbix_agentd_conf
	sed -i 's/Hostname=Zabbix server/Hostname=Zabbixclient_web${zabbix_IP}/' $zabbix_agentd_conf
	sed -i 's/#.*EnableRemoteCommands=0/EnableRemoteCommands=1/' $zabbix_agentd_conf
	sed -i 's/#.*UnsafeUserParameters=0/UnsafeUserParameters=1/' $zabbix_agentd_conf
}


install_zabbix_agent(){
	tar xf ${zabbix_version}${format1}
	cd $zabbix_version
	./configure --prefix=/usr/zabbix --enable-agent
	make install
	zabbix_agent_C
	E_PATH
	useradd -s /sbin/nologin zabbix
	zabbix_agentd
}


#This function will check depend software and install them.
solve_depend(){
	language
	if [ $? -eq 0 ];then
		echo -en "\033[1;34m正在安装依赖包,请稍后...\033[0m"
	else
		echo -e "\033[1;34mInstalling dependent software,please wait a moment...\033[0m"
	fi
	case $1 in
	  nginx)
		rpmlist="gcc pcre-devel openssl-devel zlib-devel make"
		;;
	esac
	for i in $rpmlist
	  do
		rpm -q $i &>/dev/null
		    if [ $? -ne 0 ];then
			yum -y install $i
	        fi
	  done
}

#Install Nginx
install_nginx(){
	solve_depend nginx
	grep -q nginx /etc/passwd
	if [ $? -ne 0 ];then
	    useradd -s /sbin/nologin nginx
	fi
	if [ -f ${nginx_version}.${format1} ];then
		tar -xf ${nginx_version}.${format1}
		cd $nginx_version
		./configure --prefix=/usr/local/nginx --with-http_ssl_module
		make
		make install
		ln -s /usr/local/nginx/sbin/nginx /usr/sbin/
		cd ..
	else
		error_nofile Nginx
	fi
}

#调用执行函数,安装部署LNMP,zabbix环境.
while :
do
menu
choice
case $select in
1)
	install_nginx
	;;
2)
	install_mysql
	;;
3)
	install_php
	;;
4)
	install_zabbix_server
	;;
5)
	install_zabbix_agent
	;;
6)
	exit
	;;
*)
	echo Sorry!
	;;
esac
done
