#!/bin/bash
source 00.install.env


read -p "do you install test server? (y|n) : " STATUS

if [ $STATUS = "y" ]
then
        cd ${INSTALL}
        rm -rf ${DEFAULT_NAMO} &&
        cp ${NAMO_B} ${NAMOPATH} &&
        cd ${NAMOPATH} &&
        tar xvf namo.tar &&
        rm -f ${NAMOPATH}namo.tar &&

        cd ${DEFAULT_NAMO}/websource/jsp/
        sed -i '1,1s/UTF/utf/g' EditorAuth.jsp
        sed -i '1,1s/UTF/utf/g' FileUpload.jsp
        sed -i '1,1s/;c/; c/g' FileUpload.jsp
        sed -i '1,1s/UTF/utf/g' ImageUpload.jsp
        sed -i '1,1s/UTF/utf/g' ImageUploadExecute.jsp
        sed -i '2,2s/UTF/utf/g' SaveAs.jsp
        sed -i '1,1s/UTF/utf/g' SecurityTool.jsp
        sed -i '1,1s/UTF/utf/g' TemplateLoad.jsp
        sed -i '1,1s/;c/; c/g' ImageUpload.jsp
        cd ${DEFAULT_NAMO}/manage/jsp/
        sed -i '1,1s/;c/; c/g' account_proc.jsp
        sed -i '1,1s/;c/; c/g' account_setting.jsp
        sed -i '1,1s/;c/; c/g' login_proc.jsp
        sed -i '1,1s/;c/; c/g' logout.jsp
        sed -i '1,1s/;c/; c/g' manager_preview.jsp
        sed -i '1,1s/;c/; c/g' manager_proc.jsp
        sed -i '1,1s/;c/; c/g' manager_setting.jsp
        sed -i '1,1s/;c/; c/g' update_check.jsp

        cd ${DEFAULT_NAMO}/websource/jsp/

        sed -i '2d' ImagePath.jsp
        sed -i '30d' ImagePath.jsp
        sed -i '14,15d' ImagePath.jsp

        read -p "scheme 1) http    2) https >>" SCHEME
        if [ ${SCHEME} -eq 1 ];
        then
                if [ -z ${DOMAIN} ];
                then
                        sed -i '\/\/image/a String namoImageUPath = \"http:\/\/'"$IP"':'"$HTTP"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/image/a String namoImagePhysicalPath = \"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i '10,11d' ImagePath.jsp
                        sed -i '\/\/movie/a String namoFlashUPath = \"http:\/\/'"$IP"':'"$HTTP"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/movie/a String namoFlashPhysicalPath = \"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i '6,7d' ImagePath.jsp
                        sed -i '\/\/filelink/a String namoFileUPath = \"http:\/\/'"$IP"':'"$HTTP"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/filelink/a String namoFilePhysicalPath =\"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i "s/websourchPath/http:\/\/$IP:$HTTP\/editorImage\/namo\//g" ImagePath.jsp
                        #sed -i "s/websourcePath/http:\/\/$IP:8080\/editorImage\/namo\/" ImagePath.jsp
                else
                        sed -i '\/\/image/a String namoImageUPath = \"http:\/\/'"${DOMAIN}"':'"$HTTP"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/image/a String namoImagePhysicalPath = \"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i '10,11d' ImagePath.jsp
                        sed -i '\/\/movie/a String namoFlashUPath = \"http:\/\/'"${DOMAIN}"':'"$HTTP"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/movie/a String namoFlashPhysicalPath = \"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i '6,7d' ImagePath.jsp
                        sed -i '\/\/filelink/a String namoFileUPath = \"http:\/\/'"${DOMAIN}"':'"$HTTP"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/filelink/a String namoFilePhysicalPath =\"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i "s/websourchPath/http:\/\/$DOMAIN:$HTTP\/editorImage\/namo\//g" ImagePath.jsp
                        #sed -i "s/websourcePath/http:\/\/$IP:8080\/editorImage\/namo\/" ImagePath.jsp


                fi
        else
                if [ -z ${DOMAIN} ];
                then
                        sed -i '\/\/image/a String namoImageUPath = \"https:\/\/'"$IP"':'"$HTTPS"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/image/a String namoImagePhysicalPath = \"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i '10,11d' ImagePath.jsp
                        sed -i '\/\/movie/a String namoFlashUPath = \"https:\/\/'"$IP"':'"$HTTPS"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/movie/a String namoFlashPhysicalPath = \"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i '6,7d' ImagePath.jsp
                        sed -i '\/\/filelink/a String namoFileUPath = \"https:\/\/'"$IP"':'"$HTTPS"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/filelink/a String namoFilePhysicalPath =\"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i "s/websourchPath/https:\/\/$IP:$HTTP\/editorImage\/namo\//g" ImagePath.jsp
                        #sed -i "s/websourcePath/http:\/\/$IP:8080\/editorImage\/namo\/" ImagePath.jsp
                else
                        sed -i '\/\/image/a String namoImageUPath = \"https:\/\/'"${DOMAIN}"':'"$HTTPS"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/image/a String namoImagePhysicalPath = \"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i '10,11d' ImagePath.jsp
                        sed -i '\/\/movie/a String namoFlashUPath = \"https:\/\/'"${DOMAIN}"':'"$HTTPS"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/movie/a String namoFlashPhysicalPath = \"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i '6,7d' ImagePath.jsp
                        sed -i '\/\/filelink/a String namoFileUPath = \"https:\/\/'"${DOMAIN}"':'"$HTTPS"'\/editorImage\";' ImagePath.jsp
                        sed -i '\/\/filelink/a String namoFilePhysicalPath =\"'"${M_EDIT}"'";' ImagePath.jsp
                        sed -i "s/websourchPath/https:\/\/$DOMAIN:$HTTP\/editorImage\/namo\//g" ImagePath.jsp
                        #sed -i "s/websourcePath/http:\/\/$IP:8080\/editorImage\/namo\/" ImagePath.jsp
                fi

        fi
        sed -i '7d' ImagePath.jsp
        sed -i '10d' ImagePath.jsp
        sed -i '13d' ImagePath.jsp
fi
