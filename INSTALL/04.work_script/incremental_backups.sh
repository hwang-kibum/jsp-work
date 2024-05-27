#!/bin/bash

ID='root'
PW='Wlfks@09!@#'
PATH='/data/backup/incremental_backup'
DAYS=$(/usr/bin/date +%Y-%m-%d)

TMP_DAYS=7
TMP_MONTH=3
OLD_DAYS=$(/usr/bin/date -d "${TMP_DAYS} days ago" +"%Y-%m-%d") #N 일 전
OLD_MONTH=$(/usr/bin/date -d "${TMP_MONTH} month ago" +"%Y-%m-%d") #N 개월 전

OLDDAY=$OLD_DAYS

echo ${OLD_DAYS}
# 선행 작업.
#mariadb-backup --backup --history --no-lock --user=${ID} --password=${PW} --target-dir=${PATH}/${DAYS}


function old_backup_check {
        if [ -d ${PATH}/${OLDDAY} ];then
                echo "${OLDDAY} exist"
                backup_ref_basedir
        else
                echo "${PATH}/${OLDDAY} directory not exist"
                exit
        fi
}

function backup_ref_basedir {
        /usr/bin/mariadb-backup --backup \
                --history --no-lock \
                --user=${ID} --password=${PW} \
                --target-dir=${PATH}/${DAYS} \
                --incremental-basedir=${PATH}/${OLDDAY}
}


old_backup_check
