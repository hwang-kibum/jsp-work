#!/bin/bash
#########################################
# import uitil variable & Function
source 00.util_Install_latest
source function.sh
echo "!!!jdk install start!!!"

read -p "/install dir is \"/\" in lower exist? (y|n): " STATUS

if [ ${STATUS} = "y" ] 
then
	echo "install start"

	FIN="${DATA}/java/bin/jar"
	if [ -e $FIN ]
	then 
		echo "JAVA already exist..."
		cd ${DATA}/java
		pwd
	else	
		mkdir ${DATA}
		cp -av ${JDK_PATH}/${JDK}.${JTAR} ${DATA}
		cd ${DATA} && tar -zxvf ${JDK}.${JTAR} && mv ${JDK_V} java &&
		#cp -av ${JDK} ${JAVA} && cd ${JAVA} && tar xvf ${JDK} &&  
		echo "export JAVA_HOME=\"${DATA}/java\"" >> /etc/profile &&
		echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> /etc/profile &&
		echo "export CLASSPATH=\".:\$JAVA_HOME/jre/lib/ext:\$JAVA_HOME/lib/tools.jar\"" >>/etc/profile &&
		source /etc/profile

		echo " "
		java -version
		clear_line
		echo "!!! please input command!!!"
		echo "source /etc/profile"
		
		liner
		echo "!!!jdk install complit!!!"
		echo "Start 03.tomcat_install.sh"
		
	fi
else
	echo "install dir PATH change \"/\" in the lower"
	exit
fi

