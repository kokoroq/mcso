#!/bin/bash
#
# Minecraft Complex Server Operator (MCSO)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
# This script is a update script for Minecraft Server
# 
# NO EDIT THIS FILE
#

# read mcso.conf
source /etc/mcso/mcso.conf


# Function for start
func_online_download () {
    # BE or JAVA ?
    echo "Do you want to update BE or Java?"
    read -p "BE / Java :" ou_select
    echo -e "\n"
    mkdir /tmp/update_dir
    if [ "$ou_select" = "BE" ] || [ "$ou_select" = "be" ]; then
        # Download process
        echo "Enter the URL of the Minecraft BE server application"
        read -p "> " be_url
        echo "Now Downloading..."
        wget -v -P /tmp/update_dir $be_url
        test -f /tmp/update_dir/bedrock-server*.zip
        if [ $? -eq 0 ];then
            echo "Download successfully!"
            app_name=`basename /tmp/update_dir/bedrock-server*.zip`
            be_new_ver=`echo $app_name | sed -r "s/bedrock-server-(.*)\.zip$/\1/"`
        else
            echo "Download failed..."
            echo "Stop update"
            rm -rf /tmp/update_dir
            sleep 2
            exit 1
        fi
    elif [ "$ou_select" = "Java" ] || [ "$ou_select" = "java" ] || [ "$ou_select" = "JAVA" ]; then
        # Download process
        echo "Enter the version to download new minecraft server application"
        read -p "> " java_new_ver
        echo -e "\n"
        echo "Enter the URL of the Minecraft Java server application"
        read -p "> " java_url
        echo "Now Downloading..."
        wget -v -P /tmp/update_dir $java_url
        test -f /tmp/update_dir/server.jar
        if [ $? -eq 0 ];then
            echo "Download successfully!"
            mv /tmp/update_dir/server.jar "/tmp/update_dir/minecraft_server."$java_new_ver".jar"
        else
            echo "Download failed..."
            echo "Stop update"
            rm -rf /tmp/update_dir
            sleep 2
            exit 1
        fi
    fi
}

func_local_repository () {
    # Found application path
    mkdir /tmp/update_dir
    while read LINE
    do
        app_path=$LINE
    done < /tmp/update_path.txt
    rm -f /tmp/update_path.txt
    app_name=`basename $app_path`
    mv $app_path /tmp/update_dir
    if [[ "$app_name" = *".jar" ]] && [[ "$app_name" != "minecraft_server."*".jar" ]]; then
        echo "--- Rename Java application ---"
        echo "Enter the version of new minecraft server application"
        read -p "> " java_new_ver
        mv /tmp/update_dir/$app_name /tmp/update_dir/minecraft_server."$java_new_ver".jar
    elif [[ "$app_name" = "minecraft_server."*".jar" ]]; then
        java_new_ver=`echo $app_name | sed  -r "s/minecraft_server\.(.*)\.jar$/\1/"`
    elif [[ "$app_name" = "bedrock-server-"*".zip" ]]; then
        be_new_ver=`echo $app_name | sed -r "s/bedrock-server-(.*)\.zip$/\1/"`
    else
        echo "This file is not update file"
        echo "Please check it"
        rm -rf /tmp/update_dir
        sleep 2
        exit 1
    fi
}

func_update () {
    # Update application
    # Logging update time
    TIME=`date "+%Y%m%d_%H%M%S"`

    # 1. Select BE or Java
    if [ -e /tmp/update_dir/bedrock-server*.zip ]; then
        echo "- Found new BE application"
        #  [If applicable] Stop Server
        stopcount=0
        online=`tmux list-window 2>&1 | grep $TMUX_BE_WINDOW$BE_COUNT | wc -l`
        if [ $online -eq 1 ]; then
            echo "Stop the Server..."
            tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_BE_WINDOW$BE_COUNT "say Back up the system. " C-m
            $MCSO_DIR/stop_mcso.sh -b > /dev/null
            stopcount=1
        fi

        # 2. Backup old files
        echo "- Backup old application"
        mkdir ~/old_minecraft_be_server_backup >/dev/null
        cp -ar $MS_BE_DIR/* ~/old_minecraft_be_server_backup/
        
        # 3. Update files
        echo "- Update files"
        rm -rf $MS_BE_DIR/*
        cp /tmp/update_dir/bedrock-server*.zip $MS_BE_DIR
        cd $MS_BE_DIR
        unzip $MS_BE_DIR/bedrock-server*.zip -d $MS_BE_DIR 2>&1 >/dev/null

        # 4. Restore server data
        echo "- Restore server data"
        rm -f $MS_BE_DIR/allowlist.json
        rm -f $MS_BE_DIR/permissions.json
        rm -f $MS_BE_DIR/server.properties

        cp ~/old_minecraft_be_server_backup/allowlist.json $MS_BE_DIR/
        cp ~/old_minecraft_be_server_backup/permissions.json $MS_BE_DIR/
        cp ~/old_minecraft_be_server_backup/server.properties $MS_BE_DIR/
        cp -r ~/old_minecraft_be_server_backup/worlds $MS_BE_DIR/

        # 5. Delete update file
        echo "- Delete update file"
        rm -rf /tmp/update_dir

        # 6. Logging updated time
        echo "Updated BE application to $be_new_ver" > $LOG_BE_DIR/BE_app_update_$TIME.log
        echo "UPDATE TIME: $TIME" > $LOG_BE_DIR/BE_app_update_$TIME.log

        # 7. Create application version infomation file
        echo $be_new_ver > $MS_BE_DIR/be_version.txt

        echo "#################################"
        echo "Update Completed !!"
        echo "#################################"

        # [If applicable] Restart Server
        if [ $stopcount -eq 1 ]; then
            echo "Restart the Server!"
            $MCSO_DIR/start_mcso.sh -b > /dev/null
        fi
    elif [ -e /tmp/update_dir/minecraft_server.*.jar ]; then
        echo "- Found new Java application"
        #  [If applicable] Stop Server
        stopcount=0
        online=`tmux list-window 2>&1 | grep $TMUX_JAVA_WINDOW$JAVA_COUNT | wc -l`
        if [ $online -eq 1 ]; then
            echo "Stop the Server..."
            tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_JAVA_WINDOW$JAVA_COUNT "say Back up the system. " C-m
            $MCSO_DIR/stop_mcso.sh -j > /dev/null
            stopcount=1
        fi

        # 2. Backup old files
        echo "- Backup old application"
        mkdir ~/old_minecraft_java_server_backup >/dev/null
        cp -ar $MS_JAVA_DIR/* ~/old_minecraft_java_server_backup/
        
        # 3. Delete application of current version
        echo "- Delete application of current version"
        rm -f $MS_JAVA_JAR

        # 4. Update files
        echo "- Update"
        cp /tmp/update_dir/minecraft_server."$java_new_ver".jar $MS_JAVA_DIR

        # 5. Modify Java application name for mcso.conf
        echo "- Modify mcso.conf"
        current_version_name=`basename $MS_JAVA_JAR`
        sed -i -e "s/$current_version_name/minecraft_server."$java_new_ver".jar/" /etc/mcso/mcso.conf

        # 6. Delete update file
        echo "- Delete update file"
        rm -rf /tmp/update_dir

        # 7. Logging updated time
        echo "Updated Java application to $java_new_ver" > $LOG_JAVA_DIR/Java_app_update_$TIME.log
        echo "UPDATE TIME: $TIME" >> $LOG_JAVA_DIR/Java_app_update_$TIME.log
        
        # 8. Create application version infomation file
        echo $java_new_ver > $MS_JAVA_DIR/java_version.txt

        echo "#################################"
        echo "Update Completed !!"
        echo "#################################"

        # [If applicable] Restart Server
        if [ $stopcount -eq 1 ]; then
            echo "Restart the Server!"
            $MCSO_DIR/start_mcso.sh -j > /dev/null
        fi
    else
        echo "Not Found update data"
        echo "Please check the directory"
        exit 1
    fi
}

# Main
# Select Process
case $1 in
    -o ) func_online_download; func_update ;;
    -f ) func_local_repository; func_update ;;
esac
