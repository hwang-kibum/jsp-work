#/bin/bash 
BAKPATH="/data/backup/autobackup"
TMP_FILE="${BAKPATH}/FILE"
TMP_EDIT="${BAKPATH}/EDIT"

RESTORE_FILE="/data/miso"
RESTORE_EDIT="/data/miso"




function restore_file(){
  mkdir ${TMP_FILE}
  find ${BAKPATH} -type f -name '*FILE*part*' -exec mv {} -v ${TMP_FILE} \;
  cat ${TMP_FILE}/FILE-* | tar -zxvf - -C ${RESTORE_FILE}
}

function restore_edit(){
  mkdir ${TMP_EIDT}
  find ${BAKPATH} -type f -name '*EDIT*part*' -exec mv {} -v ${TMP_EDIT} \;
  cat ${TMP_EDIT}/EDIT-* | tar -zxvf - -C ${RESTORE_EDIT}
}


restore_file
restore_edit

