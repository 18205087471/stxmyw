#! /bin/bash
redis=`/etc/init.d/redis_6379 status | cut -d "(" -f2 | cut -d ")" -f1`
if [ "$redis" == "11770" ]
        then
                echo "redis' is running!"
        else
                echo "redis not running!"
fi
