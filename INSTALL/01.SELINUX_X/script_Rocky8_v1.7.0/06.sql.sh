#!/bin/bash
source 00.util_Install_latest
echo "" > 07.add.sql

read -p "input DB_NAME : " DB_NAME
#echo "${DB_NAME}"
echo "CREATE DATABASE \`${DB_NAME}\` /*!40100 COLLATE 'utf8mb4_unicode_ci'*/;" > 07.add.sql

read -p "create user?(y|n) : " DB_USER_STATE

case ${DB_USER_STATE} in 
	y)
		read -p "input user name : " DB_USER
		#echo "${DB_USER}"
		read -p "input ${DB_USER} password (Upper, Lower, Special Latter, Num recommend: " DB_USER_PW
		#echo "${DB_USER_PW}"
		echo -e "input ${DB_USER} 1)localhost "
                echo -e "          2)remote(%) "
                read -p "          3)Remote select IP(10.10.0.1) :" HOST

		case ${HOST} in
			1)
				HOST="localhost"
			;;
			2)
				HOST="%"
			;;
			3)
				read -p "input Remote select IP (host: 10.10.0.1 / network: 10.10.0.% : " HOST 
			;;
			*)
				echo "Invalid answer"
			;;
		esac
		#echo "${HOST}"
		read -p "input ${DB_USER} GRANT (ALL | etc) : " GRANTS
		#echo "${GRANTS}"
			if [ $HOST == "localhost" ]
			then
				
				LOOPBACK='127.0.0.1'
    				echo "SET PASSWORD FOR 'root'@'${HOST}'=password('${DB_USER_PW}');" >> 07.add.sql
				echo "ALTER USER `root`@`${HOST}` IDENTIFIED VIA MYSQL_NATIVE_PASSWORD USING PASSWORD('${DB_USER_PW}');" >> 07.add.sql
				echo "CREATE USER '${DB_USER}'@'${HOST}' IDENTIFIED BY '${DB_USER_PW}';" >> 07.add.sql
				echo "CREATE USER '${DB_USER}'@'${LOOPBACK}' IDENTIFIED BY '${DB_USER_PW}';" >> 07.add.sql
    			
				echo "GRANT ${GRANTS} PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'${HOST}' IDENTIFIED BY '${DB_USER_PW}';" >> 07.add.sql
				echo "GRANT ${GRANTS} PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'${LOOPBACK}' IDENTIFIED BY '${DB_USER_PW}';" >> 07.add.sql
			else
   				echo "SET PASSWORD FOR 'root'@'${HOST}'=password('${DB_USER_PW}');" >> 07.add.sql
       				echo "ALTER USER `root`@`${HOST}` IDENTIFIED VIA MYSQL_NATIVE_PASSWORD USING PASSWORD('${DB_USER_PW}');" >> 07.add.sql
				echo "CREATE USER '${DB_USER}'@'${HOST}' IDENTIFIED BY '${DB_USER_PW}';" >> 07.add.sql
				echo "GRANT ${GRANTS} PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'${HOST}' IDENTIFIED BY '${DB_USER_PW}';" >> 07.add.sql
			fi

		#sed -i "6s/^miso/${DB_NAME}/" /data/miso/webapps/WEB-INF/classes/properties/system.properties
		sed -i "6s/\/miso/\/${DB_NAME}/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties	
				
		sed -i "7s/root/${DB_USER}/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties
		sed -i "8s/wlfks\@09\!\@\#/${DB_USER_PW}/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties
		#echo "UPDATE mysql.user SET password=password('Wlfks@09!@#') WHERE user='root';" >> 07.add.sql
		#echo "UPDATE mysql.user SET password=password('${DB_USER_PW}') WHERE user='${DB_USER}';" >> 07.add.sql
		sed -i "6s/10.52.9.45/localhost/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties
	;;
	*)
		echo "root user used"
		sed -i "7s/root/${ID}/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties
		sed -i "8s/wlfks\@09\!\@\#/${PW}/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties
		sed -i "6s/\/miso/\/${DB_NAME}/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties
		sed -i "6s/10.52.251.101/localhost/" ${DATA}/miso/webapps/WEB-INF/classes/properties/system.properties

	;;
esac

#취약점 조치 원격 DB서버 접근 제한.
echo "INSTALL SONAME 'simple_password_check';" >> 07.add.sql
echo "SET GLOBAL simple_password_check_minimal_length=9;" >> 07.add.sql
echo "show global variables like 'simple_password%';" >> 07.add.sql



#원격 DB 서버 접근 제한.
:<<END
read -p "DB REMOTE Deny config (y)" DB_RM
if [ $DB_RM = "y" ]
then
	echo "DB REMOTE Deny config!!"
	#echo "DELETE FROM user WHERE host='%';" >> 07.add.sql
	#echo "DELETE FROM db WHERE host='%';" >> 07.add.sql
else 
	echo "do not DB REMOTE Deny config"
fi
END


echo "FLUSH PRIVILEGES;" >> 07.add.sql
echo "use ${DB_NAME}" >> 07.add.sql

cat ${DATA}/miso/webapps/WEB-INF/classes/database/mysql/MYSQL_DDL_2_Table.sql >> 07.add.sql
cat ${DATA}/miso/webapps/WEB-INF/classes/database/mysql/MYSQL_DDL_3_PK.sql >> 07.add.sql
cat ${DATA}/miso/webapps/WEB-INF/classes/database/mysql/MYSQL_DDL_5_INDEX.sql >> 07.add.sql
cat ${DATA}/miso/webapps/WEB-INF/classes/database/mysql/MYSQL_DML_1_initData.sql >> 07.add.sql
cat ${DATA}/miso/webapps/WEB-INF/classes/database/mysql/CODE_DML.sql >> 07.add.sql
cat ${DATA}/miso/webapps/WEB-INF/classes/database/mysql/MENU_AUTH_DML.sql >> 07.add.sql 
cat ${DATA}/miso/webapps/WEB-INF/classes/database/mysql/MESSAGE_DML.sql >> 07.add.sql
cat ${DATA}/miso/webapps/WEB-INF/classes/database/mysql/PROPERTY_DML.sql >> 07.add.sql
echo " " >> 07.add.sql 

echo "delete from mysql.db where db='test';" >> 07.add.sql
echo "delete from mysql.db where db='test\\\\_%';" >> 07.add.sql

echo "07.add.sql"
