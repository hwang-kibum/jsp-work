#!/bin/bash

##########################################
source 00.util_Install_latest
echo "Tomcat config & Install start!!!"

#mkdir ${TOMCAT_DIR}

cp -av ${INSTALL}${TOMCAT_DIR}${TOMCAT}${TCOMP} ${DATA}
cd ${DATA};tar xvf ${TOMCAT}${TCOMP};
mv ${TOMCAT} tomcat;

#변수명 재정의.
#TOMCAT=tomcat;

#기존 내용 백업.
cp ${DATA}/tomcat/conf/server.xml ${DATA}/tomcat/conf/server.xml.bak

#config 파일 복사
yes|cp -av ${INSTALL}miso_conf/server.xml ${TOMCAT_CONF}

sed -i '154d' ${TOMCAT_CONF}server.xml
sed -i '154d' ${TOMCAT_CONF}server.xml

sed -i '154 i\\t<Context path="/" docBase="'"${DATA}"'/miso/webapps" reloadable="true"/>' ${TOMCAT_CONF}server.xml
sed -i '155 i\\t<Context path="/editorImage" docBase="'"${DATA}"'/miso/editorImage" reloadable="true"/>' ${TOMCAT_CONF}server.xml


echo " "
echo "!!!server.xml config complit"
echo " "
echo "!!!catalina.sh config start!!!"


#catalina.sh 파일 복사
yes|cp -av ${INSTALL}miso_conf/${CATALINA} ${TOMCAT_HOME}/bin
chmod 755 ${DATA}/tomcat/bin/catalina.sh 

sed -i '125d' ${DATA}/tomcat/bin/catalina.sh
sed -i '125 i\JAVA_HOME="'"${DATA}"'/java/"' ${DATA}/tomcat/bin/catalina.sh

ls -ahil ${DATA}/tomcat/bin/catalina.sh


sed -i 's|\${catalina.base}/logs|'${DATA}'/logs/tomcat|g' ${DATA}/logs/tomcat/conf/logging.properties 
sed -i 's|logs|'${DATA}'/logs/tomcat|g' server.xml
sed -i 's|txt|log|g' server.xml


echo " "
echo "!!!catalina.sh setting complit"
echo "!!!tomcat config complit"
echo "!!!================================!!!"
sync;sync;sync;

#rm -rf ${DATA}${TOMCAT}${TCOMP};

echo "Start 04.mariadb_latest.sh"
