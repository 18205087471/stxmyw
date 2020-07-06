mysqld=`systemctl status mysqld | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1 `
if [ "$mysqld" == "running" ]
        then
                echo "mysqld is running!"
        else
                echo "mysqld not running!"
fi

