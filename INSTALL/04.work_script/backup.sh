#!/bin/bash

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
RMOTPW="wlfks@09!"
RMOTEPATH='/home/jsp/miso_backup'
#WINRMOTEPATH='C:\\Users\\user\\Downloads\\'
RMOTEPORT=22
RM_DAY=90
RESULT=0;


# 0 KEY
# 1 SSHPASS
# 2 WIN
INDEX=2
#create dir
function checkSshpass {
        if rpm -qa | grep -q sshpass; then
                rpm -qa | grep sshpass
        else
                echo "sshpass not exist"
                exit
        fi

}


function addDir {
         ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "mkdir ${RMOTEPATH}/${DAYS}"

}
function sshpassAddDir {
         sshpass -p ${RMOTPW} ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "mkdir ${RMOTEPATH}/${DAYS}"

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

                scp -P ${RMOTEPORT} ${AT_BAK}/WEBAPPS.tar.gz ${RMOTID}@${RMOTIP}:${RMOTEPATH}
        else
                echo "webapps jump..."
        fi

}
function sshpassScpWebappsSend {
        if [ $1 -eq 2 ];then

                sshpass -p ${RMOTPW} scp -P ${RMOTEPORT} ${AT_BAK}/WEBAPPS.tar.gz ${RMOTID}@${RMOTIP}:${RMOTEPATH}
        else
                echo "webapps jump..."
        fi

}
function scpSend {
        scp -P ${RMOTEPORT} $@ ${RMOTID}@${RMOTIP}:${RMOTEPATH}/${DAYS}
}
function sshpassScpSend {
        sshpass -p ${RMOTPW} scp -P ${RMOTEPORT} $@ ${RMOTID}@${RMOTIP}:${RMOTEPATH}/${DAYS}
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

function sshpassCheckRemote {
        echo "${DAYS}" >> ${AT_BAK}/backupstatus.log
        sshpass -p ${RMOTPW} ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "ls -ahil ${RMOTEPATH}" >> ${AT_BAK}/backupstatus.log
        sshpass -p ${RMOTPW} ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "ls -ahil ${RMOTEPATH}/${DAYS}" >> ${AT_BAK}/backupstatus.log
        echo "" >> ${AT_BAK}/backupstatus.log

}



#window mkdir


#Window scp
function scpWinWebappsSend {
        if [ $1 -eq 2 ];then

                sshpass -p ${RMOTPW} scp -p ${RMOTEPORT} ${AT_BAK}/WEBAPPS.tar.gz ${RMOTID}@${RMOTIP}:${WINRMOTEPATH}
        else
                echo "webapps jump..."
        fi

}
function scpWinSend {
        sshpass -p ${RMOTPW} scp -P ${RMOTEPORT} $@ ${RMOTID}@${RMOTIP}:${WINRMOTEPATH}
}
echo "RUN BACKCUP~"
echo ${INDEX}
case ${INDEX} in
       0)
                echo "KEY"
                #LINUX Keygen
                addDir
                configBackup
                javaBackup
                tomcatBackup
                webappsCheck
                fileBackup
                editorBackup
                mariadbdump
                scpWebappsSend ${RESULT}
                scpSend ${AT_BAK}/EDIT-${DAYS}.tar.gz ${AT_BAK}/FILE-${DAYS}.tar.gz ${AT_BAK}/JAVA-${DAYS}.tar.gz ${AT_BAK}/TOMCAT-${DAYS}.tar.gz ${AT_BAK}/${DB}-${DAYS}.sql ${AT_BAK}/CNFG-${DAYS}.tar.gz
                checkRemote
               ;;

       1)
               echo "SSHPASS"
               #LINUX SSHPASS
               checkSshpass
               sshpassAddDir
               configBackup
               javaBackup
               tomcatBackup
               webappsCheck
               fileBackup
               editorBackup
               mariadbdump
               scpWebappsSend ${RESULT}
               sshpassScpSend ${AT_BAK}/EDIT-${DAYS}.tar.gz ${AT_BAK}/FILE-${DAYS}.tar.gz ${AT_BAK}/JAVA-${DAYS}.tar.gz ${AT_BAK}/TOMCAT-${DAYS}.tar.gz ${AT_BAK}/${DB}-${DAYS}.sql ${AT_BAK}/CNFG-${DAYS}.tar.gz
               sshpassCheckRemote
               ;;

       2)
               echo "WIN"
               #WINDOW SSHPASS
               checkSshpass
               configBackup
               javaBackup
               tomcatBackup
               webappsCheck
               fileBackup
               editorBackup
               mariadbdump
               scpWinWebappsSend ${RESULT}
               scpWinSend ${AT_BAK}/EDIT-${DAYS}.tar.gz ${AT_BAK}/FILE-${DAYS}.tar.gz ${AT_BAK}/JAVA-${DAYS}.tar.gz ${AT_BAK}/TOMCAT-${DAYS}.tar.gz ${AT_BAK}/${DB}-${DAYS}.sql ${AT_BAK}/CNFG-${DAYS}.tar.gz
               ;;

       *)
               echo "select INDEX config"
               exit
               ;;
esac
