#!/bin/bash
###################################################
source 00.util_Install_latest
systemctl stop mysqld
echo "!!!Mariadb Install start!!!"

echo "!!! compress open "
cp -arvp ${INSTALL}mariadb/${MARIA}${MCOMP} ${DATA}
cd ${DATA};

#rpm install
str=$(cat /etc/*-release | grep PRETTY_NAME | awk '{print $3}')
OS_VER=${str:0:1}

if [ ${OS_VER} == "8" ]
then
        echo "Rocky-8"
        rpm -Uvh --nodeps --force ${INSTALL}package/Rocky8/ncurses/*.rpm
elif [ ${OS_VER} == "9" ]
then
        echo "Rocky-9"
        rpm -Uvh --nodeps --force ${INSTALL}package/Rocky9/ncurses/*.rpm
  #심볼릭 링크 설정
        ln -s /usr/lib64/libncursesw.so.6.2 /usr/lib64/libncursesw.so.5
        ln -s /usr/lib64/libform.so.6.2 /usr/lib64/libform.so.5
        ln -s /usr/lib64/libtinfo.so.6.2 /usr/lib64/libtinfo.so.5
        ln -s /usr/lib64/libncursesw.so.6.2 /usr/lib64/libncurses.so.5

 #심볼릭 링크 확인.
        ls -ahil /usr/lib64/libncursesw.so.5
        ls -ahil /usr/lib64/libform.so.5
        ls -ahil /usr/lib64/libtinfo.so.5
        ls -ahil /usr/lib64/libncurses.so.5

else
        echo "not redhat linux ..."
        str=$(cat /etc/*-release | grep PRETTY_NAME | awk '{print $2}')
        OS_VER=${str:0:2}
        str=$(cat /etc/*-release | grep PRETTY_NAME | awk '{print $1}')
        OS_NAME=${str:13:6}
        echo ${OS_NAME} ${OS_VER}

        if [ ${OS_NAME} == "Ubuntu" ]
        then
                dpkg -i ${INSTALL}package/Ubuntu/ncurses/*.deb
        else
                "Not Know...OS..."
                exit
        fi
fi



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

# mariadb.service 원본 복사 {
cp -arp ${MARIA_HOME}/support-files/systemd/mariadb.service ${MARIA_HOME}/support-files/systemd/mariadb.service.origin


  # 주석제거 
sed -i '/^#/d' ${MARIA_HOME}/support-files/systemd/mariadb.service 

  # 공백제거
sed -i '/^\s*$/d' ${MARIA_HOME}/support-files/systemd/mariadb.service 

  # ProtectHome=true-> false
sed -i 's/ProtectHome=true/ProtectHome=false/' ${MARIA_HOME}/support-files/systemd/mariadb.service
  # 경로 변경
sed -i 's|/usr/local/mysql|/data/mariadb|' ${MARIA_HOME}/support-files/systemd/mariadb.service
sed -i 's|/usr/local/mysql|/data/mariadb|' ${MARIA_HOME}/support-files/systemd/mariadb.service
sed -i 's|/data/mariadb/data|/data/mariadb/mariadbData|' ${MARIA_HOME}/support-files/systemd/mariadb.service
sed -i 's|/data/mariadb/bin/mariadbd|/data/mariadb/bin/mariadbd-safe|' ${MARIA_HOME}/support-files/systemd/mariadb.service
sed -i 's|TimeoutStartSec=900|TimeoutStartSec=0|' ${MARIA_HOME}/support-files/systemd/mariadb.service


cp -arp ${MARIA_HOME}/support-files/systemd/mariadb.service ${MARIADB_SET}
chown mysql:mysql -R ${MARIADB_SET}/
#ls -ahil ${MARIADB_SET}
cp ${MARIADB_SET}/mariadb.service /usr/lib/systemd/system/

:<<END
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
NotifyAccess=all
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
TimeoutStartSec=900
TimeoutStopSec=900
LimitNOFILE=32768" >> ${INSTALL}miso_conf/mariadb.service 

END


systemctl daemon-reexec
systemctl daemon-reload
systemctl enable mariadb
systemctl is-enabled mariadb



:<<END
sed -i '27d' ${INSTALL}miso_conf/galera_recovery
sed -i '27aprint_default="'${DATA}'/mariadb/bin/my_print_defaults"' ${INSTALL}miso_conf/galera_recovery
cp ${INSTALL}miso_conf/galera_recovery ${MY_COMMAND}
END
#galera_recovery 수정.
sed -i 's|/usr/local/mysql|/data/mariadb|' ${MARIA_HOME}/bin/galera_recovery


#mariadb.logrotate 원본 백업
cp ${MARIA_HOME}/support-files/mariadb.logrotate ${MARIA_HOME}/support-files/mariadb.logrotate.origin
  #주석제거
sed -i '/^#/d' ${MARIA_HOME}/support-files/mariadb.logrotate
  # 공백제거
sed -i '/^\s*$/d' ${MARIA_HOME}/support-files/mariadb.logrotate 

sed -i '1d' ${MARIA_HOME}/support-files/mariadb.logrotate 
sed -i '1i '${DATA}'/logs/mariadb/*.log {' ${MARIA_HOME}/support-files/mariadb.logrotate
sed -i 's|/usr/local/mysql|/data/mariadb|' ${MAIRA_HOME}/support-files/mariadb.logrotate

cp -arp ${MARIA_HOME}/support-files/mariadb.logrotate ${MARIADB_SET}/



#cp ${INSTALL}miso_conf/mysql-log-retate ${LOGROTATE}

echo "#
# This group is read both both by the client and the server
# use it for options that affect everything
#
[client-server]

[client]
default-character-set = utf8mb4
#socket = ${DATA}/mariadb/tmp/mysql.sock

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
log-error = ${MARIADB_LOGS}/error.err
max_heap_table_size = 268435456
tmp_table_size = 268435456
local_infile=0

#log-bin=${DATA}/mariadb/mysql-bin #binnary log
#expire_logs_days=50;              #binnary log expire 
#tmpdir = /tmp:${DATA}/mariadb/tmp
#socket = ${DATA}/mariadb/tmp/mysql.sock

#max_password_errors=5
#default_password_lifetime=1
#wait_timeout=1800
#interactive_timeout=1800

#server_audit_output_type = file
#server_audit_query_log_limit = 1024
#server_audit_syslog_ident = ${DATA}/logs/mariadb/mysql-server_auditing
#server_audit_logging = 1
#server_audit_file_path = ${DATA}/logs/mariadb/server_audit.log
#server_audit_events = query_ddl,query_dcl,query_dml_no_select
#server_audit_file_rotate_size = 1000000
#server_audit_file_rotations = 10
#plugin_dir=${DATA}/mariadb/lib/plugin
#plugin_load_add=auth_ed25519
#default_authentication_plugin=ed25519



#simple_password_check = ON
#simple_password_check_minimal_length=9
#simple_password_check_digits=1
#simple_password_check_letters_same_case=1
#simple_password_check_other-characters=2
#
# include all files from the config directory
#
#!includedir /etc/my.cnf.d" > ${MARIADB_SET}/my.cnf 

cp ${MARIADB_SET}/my.cnf  /etc/my.cnf

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

#로그파일 권한
chown mysql:mysql -R ${MARIADB_LOGS}

ps -ef | grep mariadb
sync;sync;sync;


systemctl restart mariadb

#DB Permission
echo " "
echo "!!! 05.miso_install.sh"

rm -rf ${DATA}${MARIA}${MCOMP}




