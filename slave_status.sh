ansible slave -m shell -a "mysql -uroot -pGreat@1qaz2wsx -e 'show slave status\G' |grep -i yes"
