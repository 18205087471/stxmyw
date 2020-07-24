#!/bin/bash
#
total=$(free -m | sed -n '2p' | awk '{print $2}')
used=$(free -m | sed -n '2p' | awk '{print $3}')
free=$(free -m | sed -n '2p' | awk '{print $4}')
shared=$(free -m | sed -n '2p' | awk '{print $5}')
buff=$(free -m | sed -n '2p' | awk '{print $6}')
cached=$(free -m | sed -n '2p' | awk '{print $7}')
rate=`echo "scale=2;$used/$total" | bc | awk -F. '{print $2}'`
echo -e "total\tused\tfree\tshared\tbuffer\tavailable"
echo -e "${total}M\t${used}M\t${free}M\t${shared}M\t${buff}M\t${cached}M\nrate:${rate}%"
if    [ $rate -ge 80 ]
then    echo "Memory Warn"
    ps aux | grep -v USER | sort -rn -k4 | head
fi
