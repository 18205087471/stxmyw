#!/bin/bash
tar xf openssh-8.2p1.tar.gz
chown -R root.root openssh-8.2p1
cp /etc/securetty /etc/securetty.bak
echo "pts/0" >> /etc/securetty&&echo "pts/1" >> /etc/securetty&&echo "pts/2" >> /etc/securetty
rm -rf /etc/ssh/*
cd openssh-8.2p1
./configure --prefix=/usr/ --sysconfdir=/etc/ssh --with-ssl-dir=/usr/local/ssl --with-zlib --with-md5-passwords --with-pam && make && make install
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config&&cp -a contrib/redhat/sshd.init /etc/init.d/sshd&&chmod +x /etc/init.d/sshd&&chkconfig --add sshd&&chkconfig sshd on
echo "KexAlgorithms diffie-hellman-group1-sha1,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group-exchange-sha256,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group1-sha1" >> /etc/ssh/sshd_config
cp -a contrib/redhat/sshd.init /etc/init.d/sshd&&cp -a contrib/redhat/sshd.pam /etc/pam.d/sshd.pam&&chmod +x /etc/init.d/sshd&&chkconfig --add sshd
mv /usr/lib/systemd/system/sshd.service /root/
chkconfig sshd on
/etc/init.d/sshd restart
systemctl restart sshd
ssh -V
