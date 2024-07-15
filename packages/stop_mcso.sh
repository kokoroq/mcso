#!/bin/bash
#
# Minecraft Complex Server Operator (MCSO)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
# This script is a stop script for Minecraft Server
#

# read mcso.conf
source /etc/mcso/mcso.conf

# Time
TIME=`date "+%Y%m%d_%H%M%S"`

# Timeout count
timeout=10

# Function for stop
func_stop_be () {
    online=`tmux list-windows -t $TMUX_MASTER_SESSION 2>&1 | grep $TMUX_BE_WINDOW$BE_COUNT | wc -l`
    if [ $online -eq 0 ]; then
        echo "Minecraft BE Server is not running"
    else
        echo "Start shutdown process for Minecraft BE Server"
        echo -n "Announcing to users..."

        sleepcount=0
        tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_BE_WINDOW$BE_COUNT "say The Server stops after 20 seconds. Please SAVE immediately!" C-m
        while [ $sleepcount -le 20 ]
        do
            echo -n "."
            sleep 1
            sleepcount=`expr $sleepcount + 1`
        done
        
        sleepcount=0
        tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_BE_WINDOW$BE_COUNT "say Shutdown server..." C-m
        while [ $sleepcount -le 3 ]
        do
            echo -n "."
            sleep 1
            sleepcount=`expr $sleepcount + 1`
        done

        sleepcount=0
        tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_BE_WINDOW$BE_COUNT "stop" C-m
        while [ $sleepcount -le 5 ]
        do
            echo -n "."
            sleep 1
            sleepcount=`expr $sleepcount + 1`
        done
        echo -e ""
        echo "Shutdown complete"

        for ((i=0; i<$timeout; i++))
        do
            online2=`ps aux | grep $MS_BE_SERVER | grep -v grep | wc -l`
            if [ $online2 -ge 1 ]; then
                sleep 5
                if [ $i -eq 9 ]; then
                    echo "Unable to confirm Minecraft BE Server stop"
                    echo "Please check tmux session"
                fi
            else
                tmux pipe-pane -t $TMUX_MASTER_SESSION:$TMUX_BE_WINDOW$BE_COUNT
                tmux kill-window -t $TMUX_MASTER_SESSION:$TMUX_BE_WINDOW$BE_COUNT
                echo "Delete BE tmux window"
                break
            fi
        done
    fi
}

func_stop_java () {
    online=`tmux list-windows -t $TMUX_MASTER_SESSION 2>&1 | grep $TMUX_JAVA_WINDOW$JAVA_COUNT | wc -l`
    if [ $online -eq 0 ]; then
        echo "Minecraft Java Server is not running"
    else
        echo "Start shutdown process for Minecraft Java Server"
        echo -n "Announcing to users..."

        sleepcount=0
        tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_JAVA_WINDOW$JAVA_COUNT "say The Server stops after 20 seconds. Please SAVE immediately!" C-m
        while [ $sleepcount -le 20 ]
        do
            echo -n "."
            sleep 1
            sleepcount=`expr $sleepcount + 1`
        done
        
        sleepcount=0
        tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_JAVA_WINDOW$JAVA_COUNT "say Shutdown server..." C-m
        while [ $sleepcount -le 3 ]
        do
            echo -n "."
            sleep 1
            sleepcount=`expr $sleepcount + 1`
        done

        sleepcount=0
        tmux send-keys -t $TMUX_MASTER_SESSION:$TMUX_JAVA_WINDOW$JAVA_COUNT "stop" C-m
        while [ $sleepcount -le 5 ]
        do
            echo -n "."
            sleep 1
            sleepcount=`expr $sleepcount + 1`
        done
        echo -e ""
        echo "Shutdown complete"

        for ((i=0; i<$timeout; i++))
        do
            online2=`jps | grep $MS_JAVA_JAR | wc -l`
            if [ $online2 -ge 1 ]; then
                sleep 5
                if [ $i -eq 9 ]; then
                    echo "Unable to confirm Minecraft Java Server stop"
                    echo "Please check tmux session"
                fi
            else
                tmux pipe-pane -t $TMUX_MASTER_SESSION:$TMUX_JAVA_WINDOW$JAVA_COUNT
                tmux kill-window -t $TMUX_MASTER_SESSION:$TMUX_JAVA_WINDOW$JAVA_COUNT
                echo "Delete Java tmux session"
                break
            fi
        done
    fi
}

# Stop Process
while getopts 'bj' opt
do
    case $opt in
        b) func_stop_be ;;
        j) func_stop_java ;;
    esac
done