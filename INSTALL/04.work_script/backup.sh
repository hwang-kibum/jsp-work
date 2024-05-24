#!/bin/bash

#해당 스크립트 ssh key를 교환후 진행해야합니다.
#자동 로그인 되진 않습니다.


DEF='/data'
MISO="${DEF}/miso"
TOM="${DEF}/tomcat"
WEB="${MISO}/webapps"
FILE="${MISO}/fileUpload"
EDIT="${MISO}/editorImage"
JV="${DEF}/java"
AT_BAK="${DEF}/backup/autobackup"

DAYS=$(date +%Y-%m-%d)

DB='miso'
D_ID='root'
D_PW='Wlfks@09!@#'
INODE='inode.info'

RMOTIP='10.52.9.244'
RMOTID='jsp'
RMOTEPATH='/home/jsp/miso_backup'
RMOTEPORT=22
RM_DAY=90
RESULT=0;


#create dir
function addDir {
         ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "mkdir ${RMOTEPATH}/${DAYS}"

}

#
function autoBackupPath {
        if [ -d ${AT_BAK} ];then
                echo "${AT_BAK} exist"
        else
                mkdir ${AT_BAK}
        fi
}

#JAVA backup
function javaBackup {
        echo "java backup"
        tar -C ${DEF} -zcvf ${AT_BAK}/JAVA-${DAYS}.tar.gz java
}
#TOMCAT backup
function tomcatBackup {
        echo "tomcat backup"
        tar -C ${DEF} --exclude=tomcat/logs/* --exclude=tomcat/work/Catalina/localhost/* -zcvf ${AT_BAK}/TOMCAT-${DAYS}.tar.gz tomcat
}

#WEBAPP backup
function webappsCheck {
        echo "webapss Check"
        # inode 생성 유무 확인
        # inode 값 비교
                #값 같으면 : RESULT =1
                #값 다르면 : RESULT=2 압축
        #
        if [ -e ${DEF}/backup/${INODE} ];then
                echo "${INODE} exist file"
                RESULT=$(ls -ahil ${MISO} | grep webapps | head -n1 | awk '{print $1}')
                VALUES=$(cat ${DEF}/backup/${INODE})

        else
                RESULT=$(ls -ahil ${MISO} | grep webapps | head -n1 | awk '{print $1}')
                VALUES=0
                #echo $RESULT > ${DEF}/backup/$INODE
                #tar -C ${MISO} -zcvf ${AT_BAK}/WEBAPPS.tar.gz webapps
        fi
        if [ ${RESULT} -eq ${VALUES} ];then
                echo "webapps backup jump"
                RESULT=1
        else
                echo ${RESULT} > ${DEF}/backup/${INODE}
                rm -rf ${AT_BAK}/WEBAPPS.tar.gz
                tar -C ${MISO} -zcvf ${AT_BAK}/WEBAPPS.tar.gz webapps
                RESULT=2
        fi
}
function webappsBackup {
        if [ $1 -eq 2 ];then
                rsyn -avz -e 'ssh -p '${RMOTEPORT}'' ${AT_BAK}/WEBAPPS.tar.gz ${RMOTEID}@${RMOTIP}:${RMOTEPATH}:${DAYS}
        else
                echo "equal inode value"
        fi
}
#FILE backup
function fileBackup {
        echo "File backup"

        tar -C ${MISO} -zcvf ${AT_BAK}/FILE-${DAYS}.tar.gz fileUpload
}
#EDIT backup
function editorBackup {
        echo "editor backup"

        tar -C ${MISO} -zcvf ${AT_BAK}/EDIT-${DAYS}.tar.gz editorImage
}

#mariadb dump
function mariadbdump {
        mysqldump -u${D_ID} -p${D_PW} --default-character-set utf8 $DB > ${AT_BAK}/${DB}-${DAYS}.sql
}
#RM DAY
function rmBackup {
        NOW=$(date +"%Y-%m-%d")
        find ${AT_BAK}/* -mtime +${RM_DAY} -exec rm -f {} \;
}
# config backup
function configBackup {
        tar -C ${MISO} -zcvf ${AT_BAK}/CNFG-${DAYS}.tar.gz config-set
}


#scp

function scpWebappsSend {
        if [ $1 -eq 2 ];then

                scp -P ${RMOTEPORT} ${AT_BAK}/WEBAPPS.tar.gz ${RMOTID}@${RMOTIP}:${RMOTEPATH}/${DAYS}
        else
                echo "webapps jump..."
        fi

}
function scpSend {
        scp -P ${RMOTEPORT} $@ ${RMOTID}@${RMOTIP}:${RMOTEPATH}/${DAYS}
}


#rsync
function rsyncSend {
        echo "rsyncSend"
}
#check remote server
function checkRemote {
        echo "${DAYS}" >> ${AT_BAK}/backupstatus.log
        ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "ls -ahil ${RMOTEPATH}" >> ${AT_BAK}/backupstatus.log
        ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "ls -ahil ${RMOTEPATH}/${DAYS}" >> ${AT_BAK}/backupstatus.log
        echo "" >> ${AT_BAK}/backupstatus.log
}
#RUN TIME  ...>

#remote server에 신규 디렉토리 생성.
addDir

#CNFG backup
configBackup

#JAVA backup
javaBackup

#TOMCAT backup
tomcatBackup

#WEBAPPS inode 확인
webappsCheck

#FILE backup
fileBackup

#EDIT backup
editorBackup

#DB backup
mariadbdump

#WEBAPPS 전송
scpWebappsSend ${RESULT}

#EDIT, FILE, JAVA, TOMCAT, DB, CNFG 전송
scpSend ${AT_BAK}/EDIT-${DAYS}.tar.gz ${AT_BAK}/FILE-${DAYS}.tar.gz ${AT_BAK}/JAVA-${DAYS}.tar.gz ${AT_BAK}/TOMCAT-${DAYS}.tar.gz ${AT_BAK}/${DB}-${DAYS}.sql ${AT_BAK}/CNFG-${DAYS}.tar.gz

#remote 서버쪽 전송 리스트 확인.
checkRemote

