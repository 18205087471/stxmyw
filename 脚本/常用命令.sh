ssh-keygen -f /root/.ssh/id_rsa -N ''

java -Xms6024m -Xmx6024m -jar xxxx.jar
kill -9 `ps -ef|grep -v grep|grep .jar| awk '{ print $2 }'`
innobackupex --user=root --password=Great@1qaz2wsx  /data >2>&1
for i in {auth-server,file-center,log-center,statistics-center,supervise-center,system-center,user-center,work-center,queue-center};do `nohup java -jar /usr/java-jar/$i.jar >/dev/null 2>&1 &` sleep 0.5;done

innobackupex --defaults-file=/etc/my.cnf --no-timestamp --user=root --password=Great@1qaz2wsx --socket=/var/lib/mysql/mysql.sock /data/mybak/full/back_22-11-2019/

innobackupex --defaults-file=/etc/my.cnf --user=root --use-memory=4G --apply-log

innobackupex --defaults-file=/etc/my.cnf --user=root --password=Great@1qaz2wsx  --use-memory=4G --copy-back /backup/full/back_19-11-2019

ssh-keyscan 192.168.4.{5..7} node{5..7} >> ~/.ssh/known_hosts

for i in {177..182};do scp 10.0.18.$i:/logs/user-center/user-center-info.log . && mv user-center-info.log ./${i}user-center-info.log; done

jps|grep -v grep|grep -v Jps|awk -F. '{print $1}'|awk '{print $2}'

df命令卡死	systemctl restart proc-sys-fs-binfmt_misc.automount

BUILD_ID=DONTKILLME

yum报错修改python解释器配置
/bin/yum
/usr/libexec/urlgrabber-ext-down

00 01 6,30 * 1 /root/arback.sh

/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-2.b14.el7.x86_64/jre/lib/management/management.properties

pip3 install --no-index --find-links=~/python/site-packages -r requirements.txt

到此系统就会自动安装项目需要的依赖包。
set global sync_binlog=20;
set global innodb_flush_log_at_trx_commit=2;
set GLOBAL sql_slave_skip_counter=1;

通过slave_skip_errors参数来跳所有错误或指定类型的错误[mysqld]#slave-skip-errors=1062,1053,1146 #跳过指定error no类型的错误#slave-skip-errors=all #跳过所有错误
跳过主从复制错误SQL
set global SQL_SLAVE_SKIP_COUNTER=1
set sql_log_bin=OFF;  执行对应错误的SQL create table db58_user_credit_general(id int); set sql_log_bin=ON;
