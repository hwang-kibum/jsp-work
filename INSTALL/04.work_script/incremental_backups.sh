#!/bin/bash

ID='root'
PW='Wlfks@09!@#'
PATH='/data/backup/incremental_backup'
DAYS=$(/usr/bin/date +%Y-%m-%d)

TMP_DAYS=1
TMP_MONTH=3
OLD_DAYS=$(/usr/bin/date -d "${TMP_DAYS} days ago" +"%Y-%m-%d") #N일 전
OLD_MONTH=$(/usr/bin/date -d "${TMP_MONTH} month ago" +"%Y-%m-%d") #N 개월 전

OLDDAY=$OLD_DAYS

echo ${OLD_DAYS}
# 선행 작업.
#mariadb-backup --backup --history --no-lock --user=${ID} --password=${PW} --target-dir=${PATH}/${DAYS}

function backup_ref_basedir {
        /usr/bin/mariadb-backup --backup \
                --history --no-lock \
                --user=${ID} --password=${PW} \
                --target-dir=${PATH}/${DAYS} \
                --incremental-basedir=${PATH}/${OLDDAY}
}

function backup_first {
        /usr/bin/mariadb-backup --backup --history --no-lock --user=${ID} --password=${PW} --target-dir=${PATH}/${DAYS}
}

function old_backup_check {
        if  [ -d ${PATH}/${DAYS} ];then
                echo "${DAYS} exist....dir"
        elif [ -d ${PATH}/${OLDDAY} ];then
                echo "${OLDDAY} exist"
                backup_ref_basedir
        else
                echo "${PATH}/${OLDDAY} directory not exist"
                backup_first
        fi
}



#############################################
#                    Run                    #
#############################################

old_backup_check

