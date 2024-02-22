#!/bin/bash

NOW=$(date +"%Y-%m-%d")
LOG_PATH1=/data/miso/logs/info
LOG_PATH2=/data/miso/logs/error
LOG_PATH3=/data/tomcat/logs
#BAK_PATH=/data/backup
DAYS=190


find ${LOG_PATH1}/* -mtime +${DAYS} -exec rm -f {} \;
find ${LOG_PATH2}/* -mtime +${DAYS} -exec rm -f {} \;
find ${LOG_PATH3}/* -mtime +${DAYS} -exec rm -f {} \;

