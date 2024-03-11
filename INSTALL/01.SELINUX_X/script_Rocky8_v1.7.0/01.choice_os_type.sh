#!/bin/bash
source 00.util_Install_latest

CURRENT_SEL=$(getenforce)
CONF_SEL=$(cat /etc/selinux/config | grep '^SELINUX=' | cut -d '=' -f2 )
if [ "Enforcing" == ${CURRENT_SEL} ];
then
	echo "SELINUX BAD config"
	echo "CURRENT SELINUX : ${CURRENT_SEL}"
	echo "if SELINUX Rule force ${CURRENT_SEL} ...tomcat & mariadb package install..."
	exit;
fi

if [ "Permissive" == ${CURRENT_SEL} ];
then
	echo "Good..."
	echo "CURRENT SELINUX : ${CURRENT_SEL}"
fi

if [ "Disabled" == ${CURRENT_SEL} ];
then
	echo "Good..."
	echo "CURRENT SELINUX : ${CURRENT_SEL}"
fi

if [ "enforcing" == ${CONF_SEL} ];
then
	echo ""
	echo ""
	echo "/etc/selinux/config setting...${CONF_SEL}"
	echo "Reboot After mariadb auto restart task not Ativing..."
	exit;
else
	echo ""
	echo ""
	echo "/etc/selinux/config setting...${CONF_SEL}"
	echo "Good Config..."
fi 

read -p "what do you install OS mode Input number? 1)GUI, 2)MINIMAL : " MODE

case ${MODE} in 
	1)
		echo "you install os mode GUI mode"
		;;
	2)
		echo "you install os mode MINIMAL mode"
			cd /INSTALL/01.SELINUX_X/package/NTP/;
			rpm -Uvh *.rpm
			cd /INSTALL/01.SELINUX_X/package/curl/;
			rpm -Uvh *.rpm
			cd /INSTALL/01.SELINUX_X/package/dmidecode/;
			rpm -Uvh *.rpm
			cd /INSTALL/01.SELINUX_X/package/semanage/;
			rpm -Uvh *.rpm
		;;
	*)
		echo "you bad choice restart script"
		;;
esac

TEXT=$(cat /INSTALL/01.SELINUX_X/miso_pack/miso.core.web-2.0.war.md5)
HS_VL=$(md5sum /INSTALL/01.SELINUX_X/miso_pack/miso.core.web-2.0.war | awk '{print $1}')

if [ $TEXT == $HS_VL ]; then
	echo ""
	echo "!!!hash value are equal"
	echo ""
	echo " md5 text  : ${TEXT}"
	echo "hash value : ${HS_VL}"
else
	echo ""
	echo "!!!hash value are not equal"
	echo ""
	echo " md5 text  : ${TEXT}"
	echo "hash value : ${HS_VL}"
fi

if [ -z ${SU_USER} ];
then
	echo "switch user client used...id"
else	
	TMP_USER=$(ls -ahhil /home/ | grep ${SU_USER} | awk '{ print $10 }')
	if [ -z ${TMP_USER} ];
	then
		echo "Create su able id"
		useradd ${SU_USER}
		passwd ${SU_USER}
	else
		echo "/home directory exist..."
	fi
fi
# 추후 service 계정 삭제 필요. 
if [ -z ${SERV_USER} ];
then
	echo "service user client userd...id"
else
	TMP_USER=$(ls -ahil /home/ | grep ${SERV_USER} | awk '{ print $10 }')
	if [ -z ${TMP_USER} ];
	then
		echo "create miso service id"
		useradd ${SERV_USER}
		passwd ${SERV_USER}
	else
		echo "/home directory exist..."
	fi
fi

if [ -z ${MY_USER} ];
then 
	echo "mysql client used...id"
else
	TMP_USER=$(ls -ahil /home/ | grep ${MY_USER} | awk '{ print $10 }')
	if [ -z ${TMP_USER} ];
	then
		echo "create mysql service id"
		useradd -Ms /bin/false ${MY_USER}
	else
		echo "/home directory exist..."
	fi
fi

echo "${DATA}"
echo "${LOGS}"
echo "${TOMCAT_LOGS}"
echo "${MARIADB_LOGS}"
echo "${DATA}/miso/config-set"


mkdir -p "${LOGS}miso"
mkdir "${TOMCAT_LOGS}"
mkdir "${TOMCAT_SET}"
mkdir "${MARIADB_LOGS}"
mkdir "${MARIADB_SET}"
mkdir -p "${DATA}/miso/config-set"


exit;
