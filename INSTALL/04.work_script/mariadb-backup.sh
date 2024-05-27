#!/bin/bash

ID='root'
PW='Wlfks@09!@#'
PATH='/data/backup/db-backup'
BAK='SQL.gz'
CORE=4


if [ -d ${PATH} ];then
        echo "${PATH} exist...directory"
        maraidb-backup --backup --user=${ID} --password=${PW} --stream=xbstream 2>backup.log | /usr/bin/pigz -p ${CORE} > ${PATH}/${BAK}
else
        mkdir -p ${PATH}
        maraidb-backup --backup --user=${ID} --password=${PW} --stream=xbstream 2>backup.log | /usr/bin/pigz -p ${CORE} > ${PATH}/${BAK}

fi

/usr/bin/cp /etc/my.cnf ${PATH}
