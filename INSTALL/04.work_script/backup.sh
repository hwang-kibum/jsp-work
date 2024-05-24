#!/bin/bash
################################################################
#                       Default Variables                      #
################################################################
INODE='inode.info'
DAYS=$(date +%Y-%m-%d)
RESULT=0
RM_DAY=30
# 0 KEY
# 1 SSHPASS
# 2 WIN
# 3 LOCAL
INDEX=0
################################################################
#                        PATH Variables                        #
################################################################
DEF='/data'
MISO="${DEF}/miso"
TOM="${DEF}/tomcat"
JV="${DEF}/java"
WEB="${MISO}/webapps"
FILE="${MISO}/fileUpload"
EDIT="${MISO}/editorImage"
AT_BAK="${DEF}/backup/autobackup"
################################################################
#                       DB/ID/PW Variables                     #
################################################################
DB='miso'
D_ID='root'
D_PW='Wlfks@09!@#'
################################################################
#                        REMOTE Variables                      #
################################################################
RMOTIP='10.52.9.244'
RMOTID='jsp'
RMOTPW="wlfks@09!"
RMOTEPATH='/home/jsp/miso_backup'
#WINRMOTEPATH='C:\\Users\\user\\Downloads\\'
RMOTEPORT=22

################################################################
#                       COMMONS Functions                      #
################################################################
############<common autobackup path check dir>############
function autoBackupPath {
        if [ -d ${AT_BAK} ];then
                echo "${AT_BAK} exist"
        else
                mkdir -p ${AT_BAK}
        fi
}

############<common java backup>############
function javaBackup {
        echo "java backup"
        tar -C ${DEF} -zcvf ${AT_BAK}/JAVA-${DAYS}.tar.gz java
}
############<common tomcat backup>############
function tomcatBackup {
        echo "tomcat backup"
        tar -C ${DEF} --exclude=tomcat/logs/* --exclude=tomcat/work/Catalina/localhost/* -zcvf ${AT_BAK}/TOMCAT-${DAYS}.tar.gz tomcat
}

############<common webacpps inode file & value check>############
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

############<common fileUpload backup>############
function fileBackup {
        echo "File backup"

        tar -C ${MISO} -zcvf ${AT_BAK}/FILE-${DAYS}.tar.gz fileUpload
}
############<common editorImage backup>############
function editorBackup {
        echo "editor backup"

        tar -C ${MISO} -zcvf ${AT_BAK}/EDIT-${DAYS}.tar.gz editorImage
}

############<common mariadbdump backup>############
function mariadbdump {
        mysqldump -u${D_ID} -p${D_PW} --default-character-set utf8 $DB > ${AT_BAK}/${DB}-${DAYS}.sql
}
############<common local backup rm>############
function rmBackup {
        NOW=$(date +"%Y-%m-%d")
        find ${AT_BAK}/* -mtime +${RM_DAY} -exec rm -f {} \;
}
############<common config backup>############
function configBackup {
        tar -C ${MISO} -zcvf ${AT_BAK}/CNFG-${DAYS}.tar.gz config-set
}

################################################################
#                            ing ..                            #
#                        rsync Functions                       #
################################################################
############ DEVing ....
############<rsync multi-param send>############
function rsyncSend {
        echo "rsyncSend"
}

############ DEVing ....
############<rsyn webapps inode file & value check>############
function webappsBackup {
        if [ $1 -eq 2 ];then
                rsyn -avz -e 'ssh -p '${RMOTEPORT}'' ${AT_BAK}/WEBAPPS.tar.gz ${RMOTEID}@${RMOTIP}:${RMOTEPATH}:${DAYS}
        else
                echo "equal inode value"
        fi
}
################################################################
#                         KEY Functions                        #
################################################################
############<KEY Create dir>############
function addDir {
         ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "mkdir ${RMOTEPATH}/${DAYS}"

}
############<KEY scp webapps send>############
function scpWebappsSend {
        if [ $1 -eq 2 ];then

                scp -P ${RMOTEPORT} ${AT_BAK}/WEBAPPS.tar.gz ${RMOTID}@${RMOTIP}:${RMOTEPATH}
        else
                echo "webapps jump..."
        fi

}

############<KEY scp webapps send>############
function scpSend {
        scp -P ${RMOTEPORT} $@ ${RMOTID}@${RMOTIP}:${RMOTEPATH}/${DAYS}
}

############<KEY send data check>############
function checkRemote {
        echo "${DAYS}" >> ${AT_BAK}/backupstatus.log
        ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "ls -ahil ${RMOTEPATH}" >> ${AT_BAK}/backupstatus.log
        ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "ls -ahil ${RMOTEPATH}/${DAYS}" >> ${AT_BAK}/backupstatus.log
        echo "" >> ${AT_BAK}/backupstatus.log
}

################################################################
#                       sshpass Functions                      #
################################################################

############<sshpass Check>############
function checkSshpass {
        if rpm -qa | grep -q sshpass; then
                rpm -qa | grep sshpass
        else
                echo "sshpass not exist"
                exit
        fi

}
############<sshpass Create dir>############
function sshpassAddDir {
         sshpass -p ${RMOTPW} ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "mkdir ${RMOTEPATH}/${DAYS}"

}
############<sshpass scp webapps send>############
function sshpassScpWebappsSend {
        if [ $1 -eq 2 ];then

                sshpass -p ${RMOTPW} scp -P ${RMOTEPORT} ${AT_BAK}/WEBAPPS.tar.gz ${RMOTID}@${RMOTIP}:${RMOTEPATH}
        else
                echo "webapps jump..."
        fi

}
############<sshpass multi-param send>############
function sshpassScpSend {
        sshpass -p ${RMOTPW} scp -P ${RMOTEPORT} $@ ${RMOTID}@${RMOTIP}:${RMOTEPATH}/${DAYS}
}
############<sshpass send data check>############
function sshpassCheckRemote {
        echo "${DAYS}" >> ${AT_BAK}/backupstatus.log
        sshpass -p ${RMOTPW} ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "ls -ahil ${RMOTEPATH}" >> ${AT_BAK}/backupstatus.log
        sshpass -p ${RMOTPW} ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "ls -ahil ${RMOTEPATH}/${DAYS}" >> ${AT_BAK}/backupstatus.log
        echo "" >> ${AT_BAK}/backupstatus.log

}
################################################################
#                       Windows Functions                      #
################################################################

############<WIN sshpass scp webapps send>############
function scpWinWebappsSend {
        if [ $1 -eq 2 ];then

                sshpass -p ${RMOTPW} scp -p ${RMOTEPORT} ${AT_BAK}/WEBAPPS.tar.gz ${RMOTID}@${RMOTIP}:${WINRMOTEPATH}
        else
                echo "webapps jump..."
        fi

}
############<WIN sshpass scp multi-param send>############
function scpWinSend {
        sshpass -p ${RMOTPW} scp -P ${RMOTEPORT} $@ ${RMOTID}@${RMOTIP}:${WINRMOTEPATH}
}


##############<Run>#################
echo "RUN BACKCUP~"
echo ${INDEX}
case ${INDEX} in
       0)
                echo "KEY"
                #LINUX Keygen
                autoBackupPath
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
               autoBackupPath
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
               autoBackupPath
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
        3)
                echo "LOCAL"
                #LOCAL BACKUP
                autoBackupPath
                configBackup
                javaBackup
                tomcatBackup
                webappsCheck
                fileBackup
                editorBackup
                mariadbdump
                ;;

       *)
               echo "select INDEX config"
               exit
               ;;
esac