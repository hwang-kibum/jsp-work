#!/bin/bash
source 00.util_Install_latest


mkdir -p ${MISOWEB}
cp -av ${INSTALL}miso_pack/${MISOWAR} ${MISOWEB}

cd ${MISOWEB};jar xvf miso.core.web-2.0.war

cd ${DATA}/miso/;
mkdir fileUpload
#cp -av ${MISO_CONF}${SYSTEM_PROP} ${SYSTEM_PROP_PATH}

#cd /install
cp ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties.bak
sed -i "6s/10.52.251.101/localhost/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties
sed -i "7s/root/${ID}/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties
sed -i "8s/wlfks\@09\!/$PW/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties
sed -i '30d' ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties
sed -i '30ifileUpload\.dir\='"$DATA"'\/miso\/fileUpload' ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties


read -p "do you install test server? (y|n) : " STATUS

if [ $STATUS = "y" ]
then
	${INSTALL}script_Rocky8_v1.7.0/namo.sh
else
	echo "client server You must do it yourself Namo Editor."
	sync;sync;sync;
	echo "Start 06.sql.sh"
	exit
fi


read -p "log type select (recommand : file | not recommand : console): " LOG_TYPE
read -p "log path (recommand : /data/logs/miso) : " LOG_PATH
echo "" > ${DATA}/miso/webapps/WEB-INF/classes/logback.properties
echo "# log Level value=DEBUG or INFO or ERROR
LOG_LEVEL=DEBUG
# log file path value:console or file
LOG_OUTPUT_TYPE=${LOG_TYPE}
# log file path
LOG_HOME=${LOG_PATH}" > ${DATA}/miso/webapps/WEB-INF/classes/logback.properties

#세션 타입아웃 10으로 수정.
sed -i 's/<session-timeout>30<\/session-timeout>/<session-timeout>10<\/session-timeout>/g' ${DATA}/miso/webapps/WEB-INF/web.xml




sync;sync;sync;

echo "Start 06.sql.sh"

