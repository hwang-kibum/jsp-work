#!/bin/bash
# PASSWORD 1 Initialasation
#
# Create date : 2022.08.02
# Last Update date : 2022.12.06
# version : 0.3
# kbhwang@jiran.com
#
#FUNCTION AREA

function liner(){

 for i in {1..50..1};
 do
  echo  -n "#"
  sleep 0.01
 done
 echo ""

}

function clear_line(){

 liner
 for i in {1..5..1};
 do
  echo " "
 done
 echo ""

}

#VARIABLBE AREA
SERVICE=""
PORT=""
#Process String split
TMP=`ps -ef | grep tomcat | awk '{ print $9 }'`
TMP=`echo ${TMP:32} | awk '{print $1}'`
#echo ${TMP}
TMP=`echo ${TMP::18}`
SER_XML=""
DOC=""
DB_ID=""
DB_PW=""
DB_NAME=""
LOCAL="localhost"
URI="/system/user/getEncPassword.do"
URI_PATH=""
INIT_ID=""
ST=""

#START SHELL...
echo "start miso id unlock & init password script"
sleep 1


 #Service
while [ true ]
do
 echo "if curl not found command... It doesn't work..."
 echo "root user shell script execute..."

 liner

#root user
USER=`whoami`
if test $USER == 'root';then
 echo "Current user root!"
else
 echo "Switching user root..."
 exit
fi

#Schema check
 liner

 read -p "choice service scheme: 1)HTTP 2) HTTPS >> " SERVICE

 case $SERVICE in
  1) SERVICE="http://"
     ;;
  2) SERVICE="https://"
     ;;
  *) echo "bad chice 1 or 2"
     continue ;;
 esac

#Service Port check.
 liner
 read -p "input service Port >> " PORT

 liner

#last user config Check
 echo "Service : ${SERVICE}    Port: ${PORT}"
 read -p "config OK? (y|n) >> " ST

 liner

echo ""
 case $ST in
  "y") echo "Good config"
       break;;
  "n") echo "reset config"
       continue;;
  *)   echo " Y or N reset config"
       continue;;
 esac
done



 #server.xml PATH
if [[ ${TMP} == "/data/tomcat/conf/" ]];
then
 echo "default path"
 SER_XML="${TMP}server.xml"
else
 echo "not default path"
 sleep 1
 read -p "input Server.xml Full path:(ex: /data/tomcat/conf/server.xml) : " SER_XML
fi



 #docBase PATH
SER_XML=`tail -25 ${SER_XML} | grep docBase`
SER_XML=`echo $SER_XML | awk -F "\"" '{ print $4 }'`

DOC="${SER_XML}/WEB-INF/classes/properties/system.properties"
if [ -f $DOC ];
then
 DB_ID=`head -15 $DOC | grep user | awk -F "=" '{ print $2 }'`
 DB_PW=`head -15 $DOC | grep password | awk -F "=" '{ print $2}'`
 DB_NAME=`head -10 $DOC | grep url | awk -F "=" '{print $2}' | awk -F "/" '{print $4}' | awk -F "?" '{print $1}'`
fi




 #CURL PASSWORD PASSING.
if [ ${SERVICE} == "http://" ];
then
 if [ ${PORT} -eq 80 ];
 then
  URI_PATH="${SERVICE}${LOCAL}${URI}"
 else
  URI_PATH="${SERVER}${LOCAL}:${PORT}${URI}"
 fi
else
 if [ ${SERVICE} == "https://" ];
 then
  if [ ${PORT} -eq 443 ];
  then
   URI_PATH="${SERVICE}${LOCAL}${URI} --insecure"
  else
   URI_PATH="${SERVICE}${LOCAL}:${PORT}${URI} --insecure"
  fi
 fi
fi
TMP_PW=`curl ${URI_PATH}`
TMP_PW=`echo ${TMP_PW} | awk -F ":" '{print $3}'`
TMP_PW=`echo ${TMP_PW} | tr -d ''`

liner

if [ -z ${TMP_PW} ];
then
 echo "ERROR...exit..."
 exit
else
 echo "TMP_PW : ${TMP_PW}"
 echo "good tmp password passing"
fi

liner

sleep 1

#ID Check
read -p "init password init id >> " INIT_ID

DB_ID=`echo ${DB_ID} | tr -d '\r'`
DB_ID=`echo ${DB_ID} | tr -d "\'"`
DB_PW=`echo ${DB_PW} | tr -d '\r'`
DB_PW=`echo ${DB_PW} | tr -d "\'"`
DB_NAME=`echo ${DB_NAME} | tr -d "\'"`
#echo "${TMP_PW}"
#INIT_ID=`echo ${INIT_ID} | tr -d "\'"`



 liner
 if [[ $DB_NAME == "" ]]; then
  echo "DB_NAME : passing Error."
  read -p "DB_NAME >> " DB_NAME
  liner
 else
  echo "DB_NAME : $DB_NAME "
 fi

 if [[ $DB_ID == "" ]]; then
  echo "DB_ID : passing Error."
  read -p "DB_ID >> " DB_ID
  liner
 else
  echo "DB_ID : $DB_ID"
 fi

 if [[ $DB_PW == "" ]]; then
  echo "DB_PW : passing Error"
  read -p "DB_PW >> " DB_PW
  liner
 else
  echo "DB_PW : $DB_PW"
 fi

while [ true ]
do
 liner
 echo "Check Database, ID, PW"
 read -p "DB_NAME : ${DB_NAME} / DB_ID : ${DB_ID} / DB_PW : ${DB_PW} (y/n) :" ST
 liner
 if test $ST == 'y';then
  echo "name, id, pw passing ok!"
  break
 else
  liner
  echo "user input data >>"
  liner
  read -p "DB_NAME >> " DB_NAME
  read -p "DB_ID >> " DB_ID
  read -p "DB_PW >> " DB_PW
  break
 fi
done

liner

echo "Passing DB NAME : ${DB_NAME}"
echo "Passing DB ID   : ${DB_ID}"
echo "Passing DB PW   : ${DB_PW}"

liner

#Query Start

echo "Query Starting..."
#echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "SELECT * FROM ${DB_NAME}.user WHERE user_id='${INIT_ID}';"`

Y=`date | awk -F "." '{ print $1"-" }' | tr -d " "`
M=`date | awk -F "." '{ print $2"-" }' | tr -d " "`
D=`date | awk -F "." '{ print $3 }' | tr -d " "`
T=`date +%T`

liner

USER=`mysql -u${DB_ID} -p${DB_PW} ${DB_NM} -Bse "SELECT user_id from ${DB_NAME}.user WHERE user_id='${INIT_ID}';"`
USER=$(mysql -u${DB_ID} -p${DB_PW} ${DB_NM} -Bse "SELECT user_id from ${DB_NAME}.user WHERE user_id='${INIT_ID}';")

if [ -z ${USER} ];
then
 echo "$USER user not find...DB"
 echo "check id..."
 exit
else
 echo "${USER} FIND!!!"
fi

liner

echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "UPDATE ${DB_NAME}.user SET last_login_dt=now() where user_id='${INIT_ID}';"`
echo -n "1. ${INIT_ID}_Last_login_date init VALUE(${Y}${M}${D} ${T})  : "
echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "SELECT last_login_dt FROM ${DB_NAME}.user WHERE user_id='${INIT_ID}';"`

liner

Y=`date | awk -F "." '{ print $1"-" }' | tr -d " "`
M=`date | awk -F "." '{ print $2"-" }' | tr -d " "`
D=`date | awk -F "." '{ print $3 }' | tr -d " "`
T=`date +%T`

echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "UPDATE ${DB_NAME}.user SET pwd_change_dt=now() where user_id='${INIT_ID}';"`
echo -n "2. ${INIT_ID}_Change_password_date init VALUE(${Y}${M}${D} ${T}) : "
echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "SELECT pwd_change_dt FROM ${DB_NAME}.user WHERE user_id='${INIT_ID}';"`

liner

echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "UPDATE ${DB_NAME}.user SET acct_state_cd='U' where user_id='${INIT_ID}';"`
echo -n "3. ${INIT_ID}_accept_status init VALUE(U) : "
echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "SELECT acct_state_cd FROM ${DB_NAME}.user WHERE user_id='${INIT_ID}';"`

liner

echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "UPDATE ${DB_NAME}.user SET acct_lock_reason_cd='NULL' where user_id='${INIT_ID}';"`
echo -n "4. ${INIT_ID}_Lock reason init VALUE(NULL) : "
echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "SELECT acct_lock_reason_cd FROM ${DB_NAME}.user WHERE user_id='${INIT_ID}';"`

liner

echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "UPDATE ${DB_NAME}.user SET invalid_login_cnt=0 where user_id='${INIT_ID}';"`

echo -n "5. ${INIT_ID}_Invalid password count init VALUE(0) : "

echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "SELECT invalid_login_cnt FROM ${DB_NAME}.user WHERE user_id='${INIT_ID}';"`

liner

echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "UPDATE ${DB_NAME}.user SET password='${TMP_PW}' where user_id='${INIT_ID}';"`

echo -n  "6. ${INIT_ID}_Password init VALUE(${TMP_PW}) : "

echo `mysql -u ${DB_ID} -p${DB_PW} ${DB_NM} -Bse "SELECT password FROM ${DB_NAME}.user WHERE user_id='${INIT_ID}';"`

liner

clear

liner

 echo "        Successful password init Complite"

liner

echo ""
echo "         1. Edge & Chrome Browser miso Connect"
echo "         2. Login ID : ${INIT_ID} / PW : 1"
echo "         3. ${INIT_ID} Changed Password..."
echo ""
liner

echo "         id lock & password changed complite..."



