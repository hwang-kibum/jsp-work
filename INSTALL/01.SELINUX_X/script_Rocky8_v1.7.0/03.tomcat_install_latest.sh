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
:<<END
yes|cp -av ${INSTALL}miso_conf/server.xml ${TOMCAT_CONF}

sed -i '154d' ${TOMCAT_CONF}server.xml
sed -i '154d' ${TOMCAT_CONF}server.xml

sed -i '154 i\\t<Context path="/" docBase="'"${DATA}"'/miso/webapps" reloadable="true"/>' ${TOMCAT_CONF}server.xml
sed -i '155 i\\t<Context path="/editorImage" docBase="'"${DATA}"'/miso/editorImage" reloadable="true"/>' ${TOMCAT_CONF}server.xml
END
sed -i '165 i\\t<Context path="/" docBase="'"${DATA}"'/miso/webapps" reloadable="true"/>' ${DATA}/tomcat/conf/server.xml
sed -i '166 i\\t<Context path="/editorImage" docBase="'"${DATA}"'/miso/editorImage" reloadable="true"/>' ${DATA}/tomcat/conf/server.xml

sed -i 's|pattern="%h %l %u %t &quot;%r&quot; %s %b" />|pattern="combined" resolveHosts="false" />|' ${DATA}/tomcat/conf/server.xml
sed -i 's|unpackWARs="true" autoDeploy="true"|unpackWARs="false" autoDeploy="false"|' ${DATA}/tomcat/conf/server.xml 
sed -i 's|maxParameterCount="1000"|maxParameterCount="1000" URIEncoding="UTF-8" enableLookups="false" server="server"|' ${DATA}/tomcat/conf/server.xml


echo " "
echo "!!!server.xml config complit"
echo " "
echo "!!!catalina.sh config start!!!"


#catalina.sh 파일 복사
:<<END
yes|cp -av ${INSTALL}miso_conf/${CATALINA} ${TOMCAT_HOME}/bin
END
cp -arp ${TOMCAT_HOME}/bin/catalina.sh ${TOMCAT_HOME}/bin/catalina.sh.origin
chmod 755 ${DATA}/tomcat/bin/catalina.sh 

sed -i '125d' ${DATA}/tomcat/bin/catalina.sh
sed -i '125 i\JAVA_HOME="'"${DATA}"'/java/"' ${DATA}/tomcat/bin/catalina.sh
sed -i '126 i\JAVA_OPTS="-Xms1024m -Xmx2048m -XX:NewSize=400m -XX:MaxNewSize=400m -XX:SurvivorRatio=4"' ${DATA}/tomcat/bin/catalina.sh
sed -i '127 i\CATALINA_OUT="'"${DATA}"'/logs/tomcat/catalina.out"' ${DATA}/tomcat/bin/catalina.sh
ls -ahil ${DATA}/tomcat/bin/catalina.sh

#log경로 변경
sed -i 's|\${catalina.base}/logs|'${DATA}'/logs/tomcat|g' ${DATA}/tomcat/conf/logging.properties 
sed -i 's|logs|'${DATA}'/logs/tomcat|g' ${DATA}/tomcat/conf/server.xml
sed -i 's|txt|log|g' ${DATA}/tomcat/conf/server.xml


echo " "
echo "!!!catalina.sh setting complit"
echo "!!!tomcat config complit"
echo "!!!================================!!!"
sync;sync;sync;

#rm -rf ${DATA}${TOMCAT}${TCOMP};

echo "Start 04.mariadb_latest.sh"
