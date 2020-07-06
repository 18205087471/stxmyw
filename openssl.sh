#!/bin/bash
tar xf openssl-1.1.1g.tar.gz
yum -y install xinetd telnet-server
cp /etc/securetty /etc/securetty.bak&&echo "pts/0" >> /etc/securetty&&echo "pts/1" >> /etc/securetty&&echo "pts/2" >> /etc/securetty
systemctl restart telnet.socket
systemctl restart xinetd
systemctl enable xinetd
systemctl enable telnet.socket
ss -lntp|grep 23
mv /usr/bin/openssl /usr/bin/openssl.bak
mv /usr/include/openssl /usr/include/openssl.bak
echo "/usr/local/lib64" >> /etc/ld.so.conf
echo "/usr/local/ssl/lib" >> /etc/ld.so.conf
cd openssl-1.1.1g/
yum -y install gcc gcc-c++ glibc make autoconf openssl openssl-devel pcre-devel pam-devel
./config --prefix=/usr/local/ssl shared zlib&& make && make install
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl
ldconfig -v
openssl version
