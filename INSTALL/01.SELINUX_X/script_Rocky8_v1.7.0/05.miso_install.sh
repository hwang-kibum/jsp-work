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
	cd ${INSTALL}
	rm -rf ${DATA}/miso/webapps/web/plugins/namo &&
	cp ${INSTALL}miso_pack/namo.tar ${DATA}/miso/webapps/web/plugins/ &&
	cd ${DATA}/miso/webapps/web/plugins &&
	tar xvf namo.tar &&
	rm -f ${DATA}/miso/webapps/web/plugins/namo.tar &&

	cd ${DATA}/miso/webapps/web/plugins/namo/websource/jsp/
	sed -i '1,1s/UTF/utf/g' EditorAuth.jsp
	sed -i '1,1s/UTF/utf/g' FileUpload.jsp
	sed -i '1,1s/UTF/utf/g' ImageUpload.jsp
	sed -i '1,1s/UTF/utf/g' ImageUploadExecute.jsp
	sed -i '2,2s/UTF/utf/g' SaveAs.jsp
	sed -i '1,1s/UTF/utf/g' SecurityTool.jsp
	sed -i '1,1s/UTF/utf/g' TemplateLoad.jsp
	sed -i '1,1s/;c/; c/g' ImageUpload.jsp
	cd ${DATA}/miso/webapps/web/plugins/namo/manage/jsp/
	sed -i '1,1s/;c/; c/g' account_proc.jsp
	sed -i '1,1s/;c/; c/g' account_setting.jsp
	sed -i '1,1s/;c/; c/g' login_proc.jsp
	sed -i '1,1s/;c/; c/g' logout.jsp
	sed -i '1,1s/;c/; c/g' manager_preview.jsp
	sed -i '1,1s/;c/; c/g' manager_proc.jsp
	sed -i '1,1s/;c/; c/g' manager_setting.jsp
	sed -i '1,1s/;c/; c/g' update_check.jsp

	cd ${DATA}/miso/webapps/web/plugins/namo/websource/jsp/

	sed -i '2d' ImagePath.jsp
	sed -i '30d' ImagePath.jsp
	sed -i '14,15d' ImagePath.jsp
	sed -i '\/\/image/a String namoImageUPath = \"http:\/\/$IP:8080\/editorImage\"' ImagePath.jsp
	sed -i '\/\/image/a String namoImagePhysicalPath = \"'"${DATA}"'/miso/editorImage\"' ImagePath.jsp
	sed -i '10,11d' ImagePath.jsp
	sed -i "\/\/movie/a String namoFlashUPath = \"http:\/\/$IP:8080\/editorImage\"" ImagePath.jsp
	sed -i '\/\/movie/a String namoFlashPhysicalPath = \"'"${DATA}"'/miso/editorImage\"' ImagePath.jsp
	sed -i '6,7d' ImagePath.jsp
	sed -i "\/\/filelink/a String namoFileUPath = \"http:\/\/$IP:8080\/editorImage\"" ImagePath.jsp
	sed -i '\/\/filelink/a String namoFilePhysicalPath =\"'"${DATA}"'/miso/editorImage\"' ImagePath.jsp
	sed -i "s/websourchPath/http:\/\/$IP:8080\/editorImage\/namo\//g" ImagePath.jsp
	#sed -i "s/websourcePath/http:\/\/$IP:8080\/editorImage\/namo\/" ImagePath.jsp

	sed -i '7d' ImagePath.jsp
	sed -i '10d' ImagePath.jsp
	sed -i '13d' ImagePath.jsp

	mkdir -p ${DATA}/miso/editorImage/namo/websource/jsp
	cp -R ${DATA}/miso/webapps/web/plugins/namo/websource/jsp/* ${DATA}/miso/editorImage/namo/websource/jsp/
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

