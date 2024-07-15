#!/bin/bash
#
# Minecraft Complex Server Operator (MCSO)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
# This script is a start script for Minecraft Server
#

# read mcso.conf
source /etc/mcso/mcso.conf

# Time
TIME=`date "+%Y%m%d_%H%M%S"`


# Function for start

func_start_be () {
    online=`tmux list-windows -t $TMUX_MASTER_SESSION 2>&1 | grep $TMUX_BE_WINDOW$BE_COUNT | wc -l`
    if [ $online -ge 1 ]; then
        echo "Minecraft BE Server is running."
        echo "If you restart the Minecraft BE Server, run the following command"
        echo "# systemctl restart minecraft-be-server"
    else
        echo "Hello! Minecraft BE Server!"
        logcount=`ls -1U $LOG_BE_DIR | wc -l`
        if [ $logcount -gt $LOG_ROTATE ]; then
            ls -1U -tr $LOG_BE_DIR | head -1 | xargs rm -f
        fi

        cd $MS_BE_DIR
        /usr/bin/tmux new-window -n $TMUX_BE_WINDOW$BE_COUNT -t $TMUX_MASTER_SESSION
        /usr/bin/tmux pipe-pane -t $TMUX_MASTER_SESSION:$TMUX_BE_WINDOW$BE_COUNT "cat > $LOG_BE_DIR/mcso_tmux_be_$TIME.log"
        if [ $CPU_AFFINITY = "Enable" ]; then
            /usr/bin/tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_BE_WINDOW$BE_COUNT "LD_LIBRARY_PATH=$MS_BE_DIR" C-m
            /usr/bin/tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_BE_WINDOW$BE_COUNT "taskset -c $CPU_NUM_BE $MS_BE_SERVER" C-m
        else
            /usr/bin/tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_BE_WINDOW$BE_COUNT "LD_LIBRARY_PATH=$MS_BE_DIR $MS_BE_SERVER" C-m
        fi
        echo "Minecraft BE Server is running"
    fi
}

func_start_java () {
    online=`tmux list-windows -t $TMUX_MASTER_SESSION 2>&1 | grep $TMUX_JAVA_WINDOW$JAVA_COUNT | wc -l`
    if [ $online -ge 1 ]; then
        echo "Minecraft Java Server is running."
        echo "If you restart the Minecraft Java Server, run the following command"
        echo "# systemctl restart minecraft-java-server"
    else
        echo "Hello! Minecraft Java Server!"
        logcount=`ls -1U $LOG_JAVA_DIR | wc -l`
        if [ $logcount -gt $LOG_ROTATE ]; then
            ls -1U -tr $LOG_JAVA_DIR | head -1 | xargs rm -f
        fi

        cd $MS_JAVA_DIR
        /usr/bin/tmux new-window -n $TMUX_JAVA_WINDOW$JAVA_COUNT -t $TMUX_MASTER_SESSION
        /usr/bin/tmux pipe-pane -t $TMUX_MASTER_SESSION:$TMUX_JAVA_WINDOW$JAVA_COUNT "cat > $LOG_JAVA_DIR/mcso_tmux_java_$TIME.log"
        if [ $CPU_AFFINITY = "Enable" ]; then
            /usr/bin/tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_JAVA_WINDOW$JAVA_COUNT "taskset -c $CPU_NUM_JAVA java -Xmx$MS_JAVA_MEM -Xms$MS_JAVA_MEM -jar $MS_JAVA_JAR nogui" C-m
        else
            /usr/bin/tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_JAVA_WINDOW$JAVA_COUNT "java -Xmx$MS_JAVA_MEM -Xms$MS_JAVA_MEM -jar $MS_JAVA_JAR nogui" C-m
        fi
        echo "Minecraft Java Server is running"
    fi
}


# Start Process
while getopts 'bj' opt
do
    case $opt in
        b) func_start_be ;;
        j) func_start_java ;;
    esac
done