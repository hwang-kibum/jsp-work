#!/bin/bash
###################################################
source 00.util_Install_latest
systemctl stop mysqld
echo "!!!Mariadb Install start!!!"

echo "!!! compress open "
cp -arvp ${INSTALL}mariadb/${MARIA}${MCOMP} ${DATA}
cd ${DATA};

#rpm install
rpm -Uvh --nodeps --force ${INSTALL}package/ncurses/*.rpm


#MCOMP를 확인하고 tar 옵션 수정 필요.
tar zxvf ${MARIA}${MCOMP};
mv ${MARIA} mariadb
#MARIA_="mariadb/"

echo "!!create diractory"
#mkdir ${MARIA_DATA}
mkdir ${MARIA_TMP}
echo " "

#cp -av ${INSTALL}${MARIA}${MCOMP} ${MARIADB}
#cd ${MARIADB};tar xvf ${MARIA}

echo "!!!create user"
#useradd -Ms /bin/false mysql
#useradd mysql


echo "Mysql install db"
cd ${MARIA_HOME}/scripts;./mysql_install_db --user=mysql --basedir=${DATA}/mariadb --datadir=$DATA/mariadb/mariadbData


echo "[Unit]
Description=MariaDB 10.3.36 database server
Documentation=man:mysqld(8)
Documentation=https://mariadb.com/kb/en/library/systemd/
After=network.target

[Install]
WantedBy=multi-user.target
Alias=mysql.service
Alias=mysqld.service


[Service]
Type=notify
PrivateNetwork=false
User=${MY_USER}
Group=${MY_USER}
CapabilityBoundingSet=CAP_IPC_LOCK
ProtectSystem=full
ReadWritePaths=-${DATA}/mariadb/mariadbData
PrivateDevices=true
ProtectHome=false
PermissionsStartOnly=true" > ${INSTALL}miso_conf/mariadb.service 

echo 'ExecStartPre=/bin/sh -c "systemctl unset-environment _WSREP_START_POSITION"' >> ${INSTALL}miso_conf/mariadb.service
echo 'ExecStartPre=/bin/sh -c "[ ! -e '${DATA}'/mariadb/bin/galera_recovery ] && VAR= || \' >> ${INSTALL}miso_conf/mariadb.service
echo ' VAR=`cd '${DATA}'/mariadb/bin/..; '${DATA}'/mariadb/bin/galera_recovery`; [ $? -eq 0 ] \' >> ${INSTALL}miso_conf/mariadb.service
echo ' && systemctl set-environment _WSREP_START_POSITION=$VAR || exit 1"' >> ${INSTALL}miso_conf/mariadb.service
echo 'ExecStart='${DATA}'/mariadb/bin/mysqld_safe $MYSQLD_OPTS $_WSREP_NEW_CLUSTER $_WSREP_START_POSITION' >> ${INSTALL}miso_conf/mariadb.service 
echo 'ExecStartPost=/bin/sh -c "systemctl unset-environment _WSREP_START_POSITION"' >> ${INSTALL}miso_conf/mariadb.service

echo "KillSignal=SIGTERM
SendSIGKILL=no
Restart=on-abort
RestartSec=5s
UMask=007
PrivateTmp=false
TimeoutStartSec=0
TimeoutStopSec=900
LimitNOFILE=32768" >> ${INSTALL}miso_conf/mariadb.service 
cp ${INSTALL}miso_conf/mariadb.service /etc/systemd/system/
ln -s /etc/systemd/system/mariadb.service /usr/lib/systemd/system/
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable mariadb




sed -i '27d' ${INSTALL}miso_conf/galera_recovery
sed -i '27aprint_default="'${DATA}'/mariadb/bin/my_print_defaults"' ${INSTALL}miso_conf/galera_recovery
cp ${INSTALL}miso_conf/galera_recovery ${MY_COMMAND}

cp ${INSTALL}miso_conf/mysql-log-retate ${LOGROTATE}

echo "#
# This group is read both both by the client and the server
# use it for options that affect everything
#
[client-server]

[client]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4

[mysqld]
port=3306
datadir = ${DATA}/mariadb/mariadbData
basedir = ${DATA}/mariadb
lower_case_table_names = 1
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
max_allowed_packet = 256M
innodb_buffer_pool_size = 12G
skip-host-cache
skip-name-resolve
log-error = ${DATA}/mariadb/mariadbData/error.err
#
# include all files from the config directory
#
#!includedir /etc/my.cnf.d" > ${INSTALL}miso_conf/my.cnf 

cp -arpv ${INSTALL}miso_conf/my.cnf /etc

#소유권 변경
chown mysql:${SERV_USER} /etc/my.cnf


cp ${MY_COMMAND}mysql ${USR_BIN}
cp ${MY_COMMAND}mysqld ${USR_BIN}
cp ${MY_COMMAND}mysqldump ${USR_BIN}
cp ${MY_COMMAND}mysqladmin ${USR_BIN}

ls -ahil ${DATA}/mariadb/bin/mysql
ls -ahil ${DATA}/mariadb/bin/mysqld
ls -ahil ${DATA}/mariadb/bin/mysqldump
ls -ahil ${DATA}/mariadb/bin/mysqladmin

chown -R mysql:mysql ${DATA}/mariadb

ps -ef | grep mariadb
sync;sync;sync;


systemd-run systemctl restart mariadb

#DB Permission
echo " "
echo "!!! 05.miso_install.sh"

rm -rf ${DATA}${MARIA}${MCOMP}



