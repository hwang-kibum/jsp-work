#!/bin/bash
mkdir INSTALL
cd INSTALL
mkdir 01.SELINUX_X
mkdir 02.SELINUX_0
mkdir 03.vada
mkdir 04.work_script 

cd 01.SELINUX_X
mkdir jdk
mkdir mariadb
mkdir miso_pack
mkdir package #mariadb,apache rpm pakage
mkdir script_Rocky8_v1.7.0
mkdir tomcat
PWD=$(pwd)
echo $PWD
cp ../../installScript/Rocky8/* ../../INSTALL/01.SELINUX_X/script_Rocky8_v1.7.0/
