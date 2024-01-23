#!/bin/bash

echo "!#########################################################!"
echo "!!! /etc/profile !!!"
tail -4 /etc/profile
printf "\n\n"
echo "!#########################################################!"
echo "!!! /data/tomcat/conf/server.xml !!!"
echo -e "69 ~ 72 Line: "
sed -n '69,72p' /data/tomcat/conf/server.xml
printf "\n"
echo -e "154 ~ 157 Line: "
sed -n '154,157p' /data/tomcat/conf/server.xml
printf "\n"
echo -e "166 ~ 168 Line: "
sed -n '166,168p' /data/tomcat/conf/server.xml
printf "\n\n"
echo "!#########################################################!"
echo "!!! /data/tomcat/bin/catalina.sh !!!"
sed -n '125,126p' /data/tomcat/bin/catalina.sh 
printf "\n\n"
echo "!#########################################################!"
echo "!!! /data/mariadb/support-files/mysql.server !!!"
sed -n '45,46p' /data/mariadb/support-files/mysql.server 
printf "\n\n"
echo "!#########################################################!"
echo "!!! /etc/my.cnf !!!"
cat /etc/my.cnf
echo "!#########################################################!"
echo "!!! /data/miso/fileUpload !!!"
ls -ahil /data/miso/ | grep fileUpload
echo "!#########################################################!"
echo "!!! /data/miso/webapps/web/plugins/namo/websource/jsp/* !!!"
echo "!#########################################################!"
echo "!!! /data/miso/webapps/web/plugins/namo/websource/jsp/* !!!"
echo "!#########################################################!"
echo "!!! /data/miso/webapps/web/plugins/namo/websource/jsp/ImagePath.jsp !!!"
sed -n '5,6p' /data/miso/webapps/web/plugins/namo/websource/jsp/ImagePath.jsp
sed -n '9,10p' /data/miso/webapps/web/plugins/namo/websource/jsp/ImagePath.jsp
sed -n '13,14p' /data/miso/webapps/web/plugins/namo/websource/jsp/ImagePath.jsp
echo " " 
sed -n '29p' /data/miso/webapps/web/plugins/namo/websource/jsp/ImagePath.jsp
echo "!#########################################################!"
echo "!!! /data/miso/webapp/WEB-INF/web.xml config !!!"
cat /data/miso/webapps/WEB-INF/web.xml | grep session-timeout 
printf "\n\n"
echo "!#########################################################!"
echo "!!! Firwall Config !!!"
firewall-cmd --list-all | grep ports 
printf "\n\n"
echo "!#########################################################!"
echo "!!! Tomcat Permission !!!"
ls -alhi /data/ | grep tomcat
printf "\n\n"
echo "!#########################################################!"
echo "!!! Reboot Auto Start Tomcat !!!"
cat /usr/lib/systemd/system/tomcat.service
printf "\n\n"
echo "!#########################################################!"
echo "!!! Firwall Config !!!"
firewall-cmd --list-all | grep ports 
printf "\n\n"
echo "!#########################################################!"
echo "!!! Selinux Config !!!"
semanage port -l | grep ssh_port_t
semanage port -l | grep mysqld_port_t
semanage port -l | grep http
printf "\n\n"
echo "!#########################################################!"
echo "!!! Tomcat Permission !!!"
ls -alhi /data/ | grep tomcat
printf "\n\n"
echo "!#########################################################!"
echo "!!! Reboot Auto Start Tomcat !!!"
cat /usr/lib/systemd/system/tomcat.service
printf "\n\n"
echo "!#########################################################!"
echo "!!! Logrotate Config !!!"
cat /etc/logrotate.d/tomcat 
echo " "
echo "!!! Logrotate Status !!!"
cat /var/lib/logrotate/logrotate.status | grep catalina.out
printf "\n\n"
cd /;
rm -rf /install/script/*

