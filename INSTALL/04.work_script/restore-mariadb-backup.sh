#!/bin/bash
RESTORE_PATH='/data/backup/db-backup'
DATA_PATH='/data/mariadb/mariadbData'
GZ='SQL.gz'
CORE=4

/usr/bin/cp ${RESTORE_PATH}/my.cnf /etc/
/usr/bin/chown mysql:mysql /etc/my.cnf

/usr/bin/pigz -dc -p ${CORE} ${RESTORE_PATH}/${GZ} | /usr/bin/mbstream -x;

/usr/bin/cd ${RESTORE_PATH};
/usr/bin/mariadb-backup --prepare --target-dir=${RESTORE_PATH} ; /usr/bin/mariadb-backup --copy-back --target-dir=${RESTORE_PATH} --datadir=${DATA_PATH}

/usr/bin/chown mysql:mysql -R ${DATA_PATH}

#/usr/bin/rm -rf ${RESTORE_PATH}/${GZ}
