#!/bin/bash

source 00.util_Install_latest

SSH=22
HTTP=8080
HTTPS=8443
DB_PORT=3306



read -p "Default Port Setting SSH:22 / HTTP:8080 / HTTPS:8443 / DB:3306 (y|n)? >" STAT
#echo "user choice : $STAT"

case $STAT in 
	y)
	firewall-cmd --permanent --zone=public --add-port=$HTTP/tcp
	firewall-cmd --permanent --zone=public --add-port=$DB_PORT/tcp
	firewall-cmd --permanent --zone=public --add-port=$HTTPS/tcp
	firewall-cmd --reload
	firewall-cmd --list-all
	;;
	n)
	read -p "SSH port input Number >" SSH
	read -p "HTTP port input Number >" HTTP
	read -p "HTTPS port input Number >" HTTPS
	read -p "DB port input Number >" DB_PORT
	
	if [ ${HTTP} -lt 1025 ] ||[ ${HTTPS} -lt 1025 ];then 
		
		setcap 'cap_net_bind_service=+ep' ${DATA}/java/bin/java
		getcap ${DATA}/java/bin/java
		touch /etc/ld.so.conf.d/java.conf;
		echo "${DATA}/java/jre/lib/amd64/jli/" > /etc/ld.so.conf.d/java.conf
		ldconfig -v | grep java
	fi






	firewall-cmd --permanent --zone=public --add-port=${SSH}/tcp
	semanage port -a ${SSH} -t ssh_port_t -p tcp
	sed -i "17s/#Port 22/Port ${SSH}/" /etc/ssh/sshd_config	
	systemctl restart sshd
	
	firewall-cmd --permanent --zone=public --add-port=${HTTP}/tcp
	#semanage port -a ${HTTP} -t http_cache_port_t -p tcp
	semanage port -a ${HTTP} -t http_port_t -p tcp
	sed -i "69s/\"8080\"/\"${HTTP}\"/" ${DATA}/tomcat/conf/server.xml
	
		
	firewall-cmd --permanent --zone=public --add-port=${HTTPS}/tcp
	semanage port -a ${HTTPS} -t http_port_t -p tcp
	sed -i "71s/\"8443\"/\"${HTTPS}\"/" ${DATA}/tomcat/conf/server.xml
	sed -i "88s/\"8443\"/\"${HTTPS}\"/" ${DATA}/tomcat/conf/server.xml
	sed -i "103s/\"8443\"/\"${HTTPS}\"/" ${DATA}/tomcat/conf/server.xml
	
	firewall-cmd --permanent --zone=public --add-port=${DB_PORT}/tcp
	semanage port -a ${DB_PORT} -t mysqld_port_t -p tcp
	sed -i "6s/3306/${DB_PORT}/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties
	sed -i "14s/3306/${DB_PORT}/" /etc/my.cnf
	systemd-run systemctl restart mariadb
	
	firewall-cmd --reload
	firewall-cmd --list-all
	
	semanage port -l | grep http
	semanage port -l | grep https
	semanage port -l | grep mysql
	semanage port -l | grep ssh
	;;
	*)
	echo "user bad choice restart script..."
	exit
	;;
esac

groupadd tomcat
useradd -g tomcat tomcat
gpasswd -a tomcat tomcat
#chown tomcat:tomcat /data/tomcat/ -R
chown ${SERV_USER}:${SERV_USER} ${DATA}/tomcat -R
chown ${SERV_USER}:${SERV_USER} ${DATA}/miso -R

FIN="/usr/lib/systemd/system/tomcat.service"
if [ -e $FIN ]; then
	echo "find file! tomcat.service" 
else
	touch ${TOMCAT_SERVICE}tomcat.service &&
	echo "[Unit]" >> ${TOMCAT_SERVICE}tomcat.service &&
	echo "Description=tomcat 8" >> ${TOMCAT_SERVICE}tomcat.service &&
	echo "After=network.target syslog.target" >> ${TOMCAT_SERVICE}tomcat.service &&
  	echo -e "\n" >> ${TOMCAT_SERVICE}tomcat.service &&
	echo "[Service]" >> ${TOMCAT_SERVICE}tomcat.service &&
	echo "Type=forking" >> ${TOMCAT_SERVICE}tomcat.service && 
	echo "User=${SERV_USER}" >> ${TOMCAT_SERVICE}tomcat.service &&
	echo "Group=${SERV_USER}" >> ${TOMCAT_SERVICE}tomcat.service &&
	echo "ExecStart=${DATA}/tomcat/bin/startup.sh start" >> ${TOMCAT_SERVICE}tomcat.service &&
	echo "ExecStop=${DATA}/tomcat/bin/shutdown.sh stop" >> ${TOMCAT_SERVICE}tomcat.service &&
    echo -e "\n" >> ${TOMCAT_SERVICE}tomcat.service &&
	echo "[Install]" >> ${TOMCAT_SERVICE}tomcat.service &&
	echo "WantedBy=multi-user.target" >> ${TOMCAT_SERVICE}tomcat.service

fi
echo "tomcat.servie config"
cat ${TOMCAT_SERVICE}tomcat.service

ln -s ${TOMCAT_SERVICE}tomcat.service /usr/lib/systemd/system/
systemctl daemon-reload

systemctl enable tomcat
systemctl start tomcat



SVDATE=0
MAXAGE=0
MAXSIZE=0

#로그 로테이트 설정 
FIN="/etc/logrotate.d/tomcat"
if [ -e $FIN ]
then
	echo "find file tomcat"
else
	read -p "logs logrotate (Recommand: 1000):  >" SVDATE
 	read -p "logs Max Age (Recommand: 190): >" MAXAGE
  	read -p "logs Max Size (INPUTDATA Megabyte) Recommand(100): >" MAXSIZE
	touch /etc/logrotate.d/tomcat &&
	echo -n "${DATA}/tomcat/logs/*.out " >> /etc/logrotate.d/tomcat &&
	echo "{" >> /etc/logrotate.d/tomcat &&
	printf "\trotate ${SVDATE}\n\tcreate\n\tcopytruncate\n\tdaily\n\tcompress\n\tcompressext .gz\n\tnotifempty\n\tdateext\n\tmaxage ${MAXAGE}\n\tmaxsize ${MAXSIZE}M\n}\n" >> /etc/logrotate.d/tomcat &&
	echo -n "${DATA}/tomcat/logs/*.log " >> /etc/logrotate.d/tomcat &&
	echo "{" >> /etc/logrotate.d/tomcat &&
	printf "\trotate ${SVDATE}\n\tcreate\n\tcopytruncate\n\tdaily\n\tcompress\n\tcompressext .gz\n\tnotifempty\n\tdateext\n\tmaxage ${MAXAGE}\n\tmaxsize ${MAXSIZE}M\n}\n" >> /etc/logrotate.d/tomcat &&
	echo -n "${DATA}/tomcat/logs/*.txt " >> /etc/logrotate.d/tomcat &&
	echo "{" >> /etc/logrotate.d/tomcat &&
	printf "\trotate ${SVDATE}\n\tcreate\n\tcopytruncate\n\tdaily\n\tcompress\n\tcompressext .gz\n\tnotifempty\n\tdateext\n\tmaxage ${MAXAGE}\n\tmaxsize ${MAXSIZE}M\n}\n" >> /etc/logrotate.d/tomcat &&
	logrotate -f /etc/logrotate.d/tomcat
fi
chown ${SERV_USER}:${SERV_USER} -R ${DATA}/java
echo "!!! tomcat logrotate config "
cat /etc/logrotate.d/tomcat


FIN="/etc/logrotate.d/miso"
if [ -e $FIN ]
then
        echo "find file miso"
else
        touch /etc/logrotate.d/miso &&
        echo -n "${DATA}/miso/logs/info/*.log " >> /etc/logrotate.d/miso
	echo -n "${DATA}/miso/logs/error/*.log " >> /etc/logrotate.d/miso &&
        echo "{" >> /etc/logrotate.d/miso &&
	printf "\trotate ${SVDATE}\n\tcreate\n\tcopytruncate\n\tdaily\n\tcompress\n\tcompressext .gz\n\tnotifempty\n\tdateext\n\tmaxage ${MAXAGE}\n\tmaxsize ${MAXSIZE}M\n}\n" >> /etc/logrotate.d/miso &&
        logrotate -f /etc/logrotate.d/miso
fi
chown ${SERV_USER}:${SERV_USER} -R ${DATA}/java
echo "!!! miso logrotate config "
cat /etc/logrotate.d/miso

chmod 640 /etc/logrotate.d/tomcat 
chmod 640 /etc/logrotate.d/miso 

logrotate /etc/logrotate.d/tomcat 
logrotate /etc/logrotate.d/miso 




#자동 재시작 TOMCAT 
chmod 744 /etc/rc.d/rc.local
: << END
echo su login -c "/data/tomcat/bin/startup.sh" >> /etc/rc.d/rc.local

#touch /usr/lib/systemd/system/rc-local.service

echo "[Install]" >> /usr/lib/systemd/system/rc-local.service
echo "WantedBy=multi-user.target" >> /usr/lib/systemd/system/rc-local.service

systemctl daemon-reload
systemctl enable --now rc-local.service
systemctl list-unit-files | grep rc.local
echo "sql backup"
mysqldump -uroot -pwlfks@09\!\@\# --default-character-set utf8 miso > Install_backukp.sql


#NTP 서버 설정(만드는 중...).

read -p "do you want to ntpd?(y/n) :" STATUS
case $STATUS in
  y)
  while :
  do 
    read -p "input IP : ( ip address / n )" IP
    if [ n != $IP ]
    then  
      iptables -A INPUT -s $IP -m state --state NEW -p udp --dport 123 -j ACCEPT
      firewall-cmd --add-service=ntp --permanent
      
      continue
    fi
    if [ n = $IP ]
      echo "add ntp ip address"
      exit
    fi
  done
esac
  iptables -A INPUT
  systemctl enable ntpd
  lsof -i udp:123
  ps -ef | grep ntpd
  

END

echo "sql backup"
mysqldump -uroot -p'Wlfks@09!@#' --default-character-set utf8 miso > Install_backukp.sql

