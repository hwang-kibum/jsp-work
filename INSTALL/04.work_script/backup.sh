#!/bin/bash
################################################################
#                       Default Variables                      #
################################################################
INODE='inode.info'
JAVER='java.info'
TOMVER='tomcat.info'
DAYS=$(date +%Y-%m-%d)
RESULT=0
RESULT_J=0
RESULT_T=0
RM_DAY=30
# 0 KEY
# 1 SSHPASS
# 2 WIN
# 3 LOCAL
INDEX=0
#SPLIT="Y" 분할 압축 1G
#SPLIT="N" 일반 백업
SPLIT="N"
SIZE="1024m"
################################################################
#                        PATH Variables                        #
################################################################
DEF='/data'
MISO="${DEF}/miso"
TOM="${DEF}/tomcat"
JV="${DEF}/java"
MARIA="${DEF}/mariadb"
WEB="${MISO}/webapps"
FILE="${MISO}/fileUpload"
EDIT="${MISO}/editorImage"
AT_BAK="${DEF}/backup/autobackup"
################################################################
#                        Daemon Variables                      #
################################################################
DAEMON_PATH="${DEF}/miso_daemon"
DAEMON_USE='N'
################################################################
#                       DB/ID/PW Variables                     #
################################################################
DB='miso'
D_ID='root'
D_PW='Wlfks@09!@#'
################################################################
#                        REMOTE Variables                      #
################################################################
RMOTIP='10.52.9.249'
RMOTID='jsp'
RMOTPW="wlfks@09!"
RMOTEPATH='/home/jsp/miso_backup'
WINRMOTEPATH='C:\\Users\\user\\Downloads\\'
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
        if [ -e ${DEF}/backup/${JAVER} ];then
                echo "${JAVER} exist file"
                JAV_TMP=$(md5sum ${JV}/bin/java | awk '{ print $1}')
                J_TMP=$(cat ${DEF}/backup/${JAVER})
        else
                JAV_TMP=$(md5sum ${JV}/bin/java | awk '{ print $1}')
                J_TMP=0
        fi
        if [ "${JAV_TMP}" == "${J_TMP}" ];then
                echo "java backup jump"
                RESULT_J=1
        else
                echo ${JAV_TMP} > ${DEF}/backup/${JAVER}
                rm -rf ${AT_BAK}/JAVA.tar.gz
                tar -C ${DEF} -zcvf ${AT_BAK}/JAVA.tar.gz java
                RESULT_J=2
        fi
}
############<common tomcat backup>############
function tomcatBackup {
        echo "tomcat backup"
        if [ -e ${DEF}/backup/${TOMVER} ];then
                echo "${TOMVER} exist file"
                TOM_TMP=$(md5sum ${TOM}/conf/server.xml | awk '{ print $1 }')
                T_TMP=$(cat ${DEF}/backup/${TOMVER})
        else
                TOM_TMP=$(md5sum ${TOM}/conf/server.xml | awk '{ print $1 }')
                T_TMP=0
        fi
        if [ ${TOM_TMP} == ${T_TMP} ];then
                echo "TOMCAT backup jump"
                RESULT_T=1
        else
                echo ${TOM_TMP} > ${DEF}/backup/${TOMVER}
                rm -rf ${AT_BAK}/TOMCAT.tar.gz
                tar -C ${DEF} --exclude=tomcat/logs/* --exclude=tomcat/work/Catalina/localhost/* -zcvf ${AT_BAK}/TOMCAT.tar.gz tomcat
                RESULT_T=2
        fi
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
        find ${AT_BAK}/* -mtime +${RM_DAY} -not -name "JAVA.tar.gz" -not -name "TOMCAT.tar.gz" -not -name "WEBAPPS.tar.gz" -exec rm -rf {} \;
}
############<common config backup>############
function configBackup {
        tar -C ${MISO} -zcvf ${AT_BAK}/CNFG-${DAYS}.tar.gz config-set
}
############<daemon backup>###################
function daemonBackup {
        tar -zcvf ${AT_BAK}/DAEMON-${DAYS}.tar.gz -C ${DEF} --exclude=logs/* miso_daemon
}
############<mariadb-backup>##################
function mariaTotalBackup {
        ${MARIA}/bin/mariadb-backup --backup --user=${D_ID} --password=${D_PW} --stream=${MARIA}/bin/xbstream 2> sql-mariadb-backup.log 
}
############<mariadb-backup Compression>##################
function mariadbTotalBackupCompression {
        ${MARIA}/bin/mariadb-backup --backup --user=${D_ID} --password=${D_PW} --stream=${MARIA}/bin/xbstream 2> sql-mariadb-backup.log | pigz -p 4 > ${AT_BAK}/SQL.gz 
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
function scpJavaSend {
        if [ $1 -eq 2 ];then

                scp -P ${RMOTEPORT} ${AT_BAK}/JAVA.tar.gz ${RMOTID}@${RMOTIP}:${RMOTEPATH}
        else
                echo "java jump..."
        fi

}
function scpTomcatSend {
        if [ $1 -eq 2 ];then

                scp -P ${RMOTEPORT} ${AT_BAK}/TOMCAT.tar.gz ${RMOTID}@${RMOTIP}:${RMOTEPATH}
        else
                echo "tomcat jump..."
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
function sshpassScpJavaSend {
        if [ $1 -eq 2 ];then

                sshpass -p ${RMOTPW} scp -P ${RMOTEPORT} ${AT_BAK}/JAVA.tar.gz ${RMOTID}@${RMOTIP}:${RMOTEPATH}
        else
                echo "java jump..."
        fi

}
function sshpassScpTomcatSend {
        if [ $1 -eq 2 ];then

                sshpass -p ${RMOTPW} scp -P ${RMOTEPORT} ${AT_BAK}/TOMCAT.tar.gz ${RMOTID}@${RMOTIP}:${RMOTEPATH}
        else
                echo "tomcat jump..."
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
function scpWinJavaSend {
        if [ $1 -eq 2 ];then

                sshpass -p ${RMOTPW} scp -p ${RMOTEPORT} ${AT_BAK}/JAVA.tar.gz ${RMOTID}@${RMOTIP}:${WINRMOTEPATH}
        else
                echo "java jump..."
        fi

}
function scpWinTomcatSend {
        if [ $1 -eq 2 ];then

                sshpass -p ${RMOTPW} scp -p ${RMOTEPORT} ${AT_BAK}/TOMCAT.tar.gz ${RMOTID}@${RMOTIP}:${WINRMOTEPATH}
        else
                echo "tomcat jump..."
        fi

}
############<WIN sshpass scp multi-param send>############
function scpWinSend {
        sshpass -p ${RMOTPW} scp -P ${RMOTEPORT} $@ ${RMOTID}@${RMOTIP}:${WINRMOTEPATH}
}
############<WIN send data check>#################
function WincheckRemote {
        echo "${DAYS}" >> ${AT_BAK}/backupstatus.log
        sshpass -p ${RMOTPW} ssh -P${RMOTEPORT} ${RMOTID}@${RMOTIP} "dir ${WINRMOTEPATH}" >> ${AT_BAK}/backupstatus.log
        echo "" >> ${AT_BAK}/backupstatus.log
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
                scpJavaSend ${RESULT_J}
                scpTomcatSend ${RESULT_T}
                scpSend ${AT_BAK}/EDIT-${DAYS}.tar.gz ${AT_BAK}/FILE-${DAYS}.tar.gz ${AT_BAK}/${DB}-${DAYS}.sql ${AT_BAK}/CNFG-${DAYS}.tar.gz
                if [ ${DAEMON_USE} == 'Y' ];then
                        daemonBackup
                        scpSend ${AT_BAK}/DAEMON-${DAYS}.tar.gz
                else
                        echo "Damonbackup pass"
                fi
                checkRemote
                rmBackup
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
               sshpassScpWebappsSend ${RESULT}
               sshpassScpJavaSend ${RESULT_J}
               sshpassScpTomcatSend ${RESULT_T}
               sshpassScpSend ${AT_BAK}/EDIT-${DAYS}.tar.gz ${AT_BAK}/FILE-${DAYS}.tar.gz ${AT_BAK}/${DB}-${DAYS}.sql ${AT_BAK}/CNFG-${DAYS}.tar.gz
                if [ ${DAEMON_USE} == 'Y' ];then
                        daemonBackup
                        sshpassScpSend ${AT_BAK}/DAEMON-${DAYS}.tar.gz
                else
                        echo "Damonbackup pass"
                fi

               sshpassCheckRemote
               rmBackup
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
               scpWinJavaSend ${RESULT_J}
               scpWinTomcatSend ${RESULT_T}
               scpWinSend ${AT_BAK}/EDIT-${DAYS}.tar.gz ${AT_BAK}/FILE-${DAYS}.tar.gz ${AT_BAK}/${DB}-${DAYS}.sql ${AT_BAK}/CNFG-${DAYS}.tar.gz
               if [ ${DAEMON_USE} == 'Y' ];then
                        daemonBackup
                        scpWinSend ${AT_BAK}/DAEMON-${DAYS}.tar.gz
                else
                        echo "Damonbackup pass"
                fi

               WincheckRemote
               rmBackup
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
                daemonBackup
                mariadbdump
                rmBackup
                ;;

       *)
               echo "select INDEX config"
               exit
               ;;
esac

                                          
