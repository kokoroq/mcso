#!/bin/bash
#
# Minecraft Complex Server Operator (MCSO)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
# This script is a backup script for Minecraft Server
#

# read mcso.conf
source /etc/mcso/mcso.conf

# Time
TIME=`date "+%Y%m%d_%H%M%S"`

#----------------------------------#
# Backup process
#----------------------------------#

#########################################
# Full backup
#########################################
full_be_backup () {
    bkcount=`ls -1U $FULL_BACKUP_BE_DIR | wc -l`
    if [ $bkcount -gt $FULL_BACKUP_ROTATE ]; then
        ls -1U -tr $FULL_BACKUP_BE_DIR | head -1 | xargs -I {} rm -f $FULL_BACKUP_BE_DIR/{}
    fi

    stopcount=0

    # If the Minecraft BE Server is running, stop it
    online=`tmux list-window 2>&1 | grep $TMUX_BE_WINDOW$BE_COUNT | wc -l`
    if [ $online -eq 1 ]; then
        echo "Stop the Server..."
        tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_BE_WINDOW$BE_COUNT "say Back up the system. " C-m
        $MCSO_DIR/stop_mcso.sh -b > /dev/null
        stopcount=1
    fi
    
    # Start BE full backup
    echo "--- Duplicating ---"
    fullbk_dir="minecraft_be_server_full_backup_$TIME"
    mkdir $BACKUP_BE_DIR/$fullbk_dir
    cp -r $MS_BE_DIR/* $BACKUP_BE_DIR/$fullbk_dir
    rm -f $BACKUP_BE_DIR/$fullbk_dir/bedrock-server-*.zip
    cd $BACKUP_BE_DIR
    tar -zcvf $FULL_BACKUP_BE_DIR/$fullbk_dir.tar.gz ./$fullbk_dir >/dev/null
    rm -rf $BACKUP_BE_DIR/$fullbk_dir

    # If the script shut down the Minecraft Server for backup, start it
    if [ $stopcount -eq 1 ]; then
        echo "Restart the Server!"
        $MCSO_DIR/start_mcso.sh -b > /dev/null
    fi
}

full_java_backup () {
    bkcount=`ls -1U $FULL_BACKUP_JAVA_DIR | wc -l`
    if [ $bkcount -gt $FULL_BACKUP_ROTATE ]; then
        ls -1U -tr $FULL_BACKUP_JAVA_DIR | head -1 | xargs -I {} rm -f $FULL_BACKUP_JAVA_DIR/{}
    fi

    stopcount=0

    # If the Minecraft Java Server is running, stop it
    online=`tmux list-window 2>&1 | grep $TMUX_JAVA_WINDOW$JAVA_COUNT | wc -l`
    if [ $online -eq 1 ]; then
        echo "Stop the Server..."
        tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_JAVA_WINDOW$JAVA_COUNT "say Back up the system" C-m
        $MCSO_DIR/stop_mcso.sh -j > /dev/null
        stopcount=1
    fi
    
    # Start Java full backup
    echo "--- Duplicating ---"
    fulljv_dir="minecraft_java_server_full_backup_$TIME"
    mkdir $BACKUP_JAVA_DIR/$fulljv_dir
    cp -r $MS_JAVA_DIR/* $BACKUP_JAVA_DIR/$fulljv_dir
    cd $BACKUP_JAVA_DIR
    tar -zcvf $FULL_BACKUP_JAVA_DIR/$fulljv_dir.tar.gz ./$fulljv_dir >/dev/null
    rm -rf $BACKUP_JAVA_DIR/$fulljv_dir

    # If the script shut down the Minecraft Server for backup, start it
    if [ $stopcount -eq 1 ]; then
        echo "Restart the Server!"
        $MCSO_DIR/start_mcso.sh -j > /dev/null
    fi
}

#########################################
# Instant backup
#########################################
instant_be_backup () {
    bkcount=`ls -1U $INSTANT_BACKUP_BE_DIR | wc -l`
    if [ $bkcount -gt $INSTANT_BACKUP_ROTATE ]; then
        ls -1U -tr $INSTANT_BACKUP_BE_DIR | head -1 | xargs -I {} rm -f $INSTANT_BACKUP_BE_DIR/{}
    fi
    instantbk_dir="minecraft_be_server_instant_backup_$TIME"
    mkdir $BACKUP_BE_DIR/$instantbk_dir
    # allowlist.json
    cp $MS_BE_DIR/allowlist.json $BACKUP_BE_DIR/$instantbk_dir
    # Dedicated_Server.txt
    cp $MS_BE_DIR/Dedicated_Server.txt $BACKUP_BE_DIR/$instantbk_dir
    # packet-statistics.txt
    cp $MS_BE_DIR/packet-statistics.txt $BACKUP_BE_DIR/$instantbk_dir
    # server.properties
    cp $MS_BE_DIR/server.properties $BACKUP_BE_DIR/$instantbk_dir
    # valid_known_packes.json
    cp $MS_BE_DIR/valid_known_packs.json $BACKUP_BE_DIR/$instantbk_dir
    # worlds
    cp -R $MS_BE_DIR/worlds $BACKUP_BE_DIR/$instantbk_dir

    cd $BACKUP_BE_DIR
    tar -zcvf $INSTANT_BACKUP_BE_DIR/$instantbk_dir.tar.gz ./$instantbk_dir >/dev/null
    rm -rf $BACKUP_BE_DIR/$instantbk_dir
}

instant_java_backup () {
    bkcount=`ls -1U $INSTANT_BACKUP_JAVA_DIR | wc -l`
    if [ $bkcount -gt $INSTANT_BACKUP_ROTATE ]; then
        ls -1U -tr $INSTANT_BACKUP_JAVA_DIR | head -1 | xargs -I {} rm -f $INSTANT_BACKUP_JAVA_DIR/{}
    fi
    instantjv_dir="minecraft_java_server_instant_backup_$TIME"
    mkdir $BACKUP_JAVA_DIR/$instantjv_dir
    # whitelist.json
    cp $MS_JAVA_DIR/whitelist.json $BACKUP_JAVA_DIR/$instantjv_dir
    # banned-ips.json
    cp $MS_JAVA_DIR/banned-ips.json $BACKUP_JAVA_DIR/$instantjv_dir
    # banned-players.json
    cp $MS_JAVA_DIR/banned-players.json $BACKUP_JAVA_DIR/$instantjv_dir
    # server.properties
    cp $MS_JAVA_DIR/server.properties $BACKUP_JAVA_DIR/$instantjv_dir
    # ops.json
    cp $MS_JAVA_DIR/ops.json $BACKUP_JAVA_DIR/$instantjv_dir
    # usercache.json
    cp $MS_JAVA_DIR/usercache.json $BACKUP_JAVA_DIR/$instantjv_dir
    # worlds
    cp -R $MS_JAVA_DIR/world $BACKUP_JAVA_DIR/$instantjv_dir
    # logs
    cp -R $MS_JAVA_DIR/logs $BACKUP_JAVA_DIR/$instantjv_dir

    cd $BACKUP_JAVA_DIR
    tar -zcvf $INSTANT_BACKUP_JAVA_DIR/$instantjv_dir.tar.gz ./$instantjv_dir >/dev/null
    rm -rf $BACKUP_JAVA_DIR/$instantjv_dir
}

#########################################
# Restore backup *** Full backup only ***
#########################################
restore_application () {
    echo "! ATTENTION !"
    echo ""
    echo "Restore will erase the current files"
    echo "Do you want to run?"
    read -p "(yes/no): " agreement_restore

    if [ "$agreement_restore" = "yes" ] || [ "$agreement_restore" = "y" ]; then
        if [ $1 = "be" ]; then
            # If the Minecraft BE Server is running, stop it
            online=`tmux ls 2>&1 | grep $TMUX_BE_SESSION$BE_COUNT | wc -l`
            if [ $online -ge 1 ]; then
                $MCSO_DIR/stop_mcso.sh -b > /dev/null
            fi

            # List files
            max_file_count=`ls -U1 $FULL_BACKUP_BE_DIR | wc -l`
            max_file_count=`expr $max_file_count - 1`
            current_file_count=0
            echo "##################################"
            echo "Select the file number to restore"
            echo "##################################"

            ls -U1 $FULL_BACKUP_BE_DIR > /tmp/restore_files_name.txt
            while read LINE
            do
                bp_file+=("$LINE")
                echo "$current_file_count:        $LINE"
                if [ $((current_file_count)) -lt $((max_file_count)) ]; then
                    current_file_count=`expr $current_file_count + 1`
                fi
            done < /tmp/restore_files_name.txt
            rm -f /tmp/restore_files_name.txt

            read -p "Select Number:  " select_re_num
            if [ $((select_re_num)) -lt 0 ] || [ $((select_re_num)) -gt $((max_file_count)) ]; then
                echo "Invalid number, Please retry to run"
                exit 1
            fi
            eval echo "Is the file to be restored correct at \( ${bp_file[$select_re_num]} \)?"          
            read -p "(yes/no): " agreement_restore_num

            # Restore
            if [ "$agreement_restore_num" = "yes" ] || [ "$agreement_restore_num" = "y" ]; then
                select_file=${bp_file[$select_re_num]}
                cp $FULL_BACKUP_BE_DIR/$select_file /tmp
                cd /tmp
                tar -zxvf /tmp/$select_file >/dev/null
                rm -rf $MS_BE_DIR/*
                cp -r /tmp/${select_file%.tar.gz}/* $MS_BE_DIR
                sudo chown -R $USERNAME:$USERGROUP $MS_BE_DIR
                rm -rf /tmp/${select_file%.tar.gz}
                rm -f /tmp/$select_file
                echo "Restore complete!"
            else
                echo "Invalid option, Please retry to run"
                exit 1
            fi
        elif [ $1 = "java" ]; then
            # If the Minecraft Java Server is running, stop it
            online=`tmux ls 2>&1 | grep $TMUX_JAVA_SESSION$JAVA_COUNT | wc -l`
            if [ $online -ge 1 ]; then
                $MCSO_DIR/stop_mcso.sh -j > /dev/null
            fi

            # List files
            max_file_count=`ls -U1 $FULL_BACKUP_JAVA_DIR | wc -l`
            max_file_count=`expr $max_file_count - 1`
            current_file_count=0
            echo "##################################"
            echo "Select the file number to restore"
            echo "##################################"

            ls -U1 $FULL_BACKUP_JAVA_DIR > /tmp/restore_files_name.txt
            while read LINE
            do
                bp_file+=("$LINE")
                echo "$current_file_count:        $LINE"
                if [ $((current_file_count)) -lt $((max_file_count)) ]; then
                    current_file_count=`expr $current_file_count + 1`
                fi
            done < /tmp/restore_files_name.txt
            rm -f /tmp/restore_files_name.txt

            read -p "Select Number:  " select_re_num
            if [ $((select_re_num)) -lt 0 ] || [ $((select_re_num)) -gt $((max_file_count)) ]; then
                echo "Invalid number, Please retry to run"
                exit 1
            fi
            eval echo "Is the file to be restored correct at \( ${bp_file[$select_re_num]} \)?"          
            read -p "(yes/no): " agreement_restore_num

            # Restore
            if [ "$agreement_restore_num" = "yes" ] || [ "$agreement_restore_num" = "y" ]; then
                select_file=${bp_file[$select_re_num]}
                cp $FULL_BACKUP_JAVA_DIR/$select_file /tmp
                cd /tmp
                tar -zxvf /tmp/$select_file >/dev/null
                rm -rf $MS_JAVA_DIR/*
                cp -r /tmp/${select_file%.tar.gz}/* $MS_JAVA_DIR
                sudo chown -R $USERNAME:$USERGROUP $MS_JAVA_DIR
                rm -rf /tmp/${select_file%.tar.gz}
                rm -f /tmp/$select_file
                echo "Restore complete!"
            else
                echo "Invalid option, Please retry to run"
                exit 1
            fi
        fi
    fi
}



case $1 in
    -fb) full_be_backup ;;
    -fj) full_java_backup ;;
    -ib) instant_be_backup ;;
    -ij) instant_java_backup ;;
    -rb) restore_application "be";;
    -rj) restore_application "java";;
esac