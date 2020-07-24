#!/bin/bash
for i in {178..182};do rsync -aSH /root/jara.sh 10.0.18.$i:/root;done
for i in {243..244};do rsync -aSH /root/jara.sh 10.0.18.$i:/root;done

w="work-center"

for i in {178..182};do rsync -aSH /usr/java-jar/${w}.jar 10.0.18.$i:/usr/java-jar/${w}.jar;done
for i in {243..244};do rsync -aSH /usr/java-jar/${w}.jar 10.0.18.$i:/usr/java-jar/${w}.jar;done
echo -e "\033[1;36m同步${w}完成!\033[0m"
