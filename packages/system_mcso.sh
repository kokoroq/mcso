#!/bin/bash
#
# Minecraft Complex Server Operator (MCSO)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
# This script is a system script for Minecraft Server
# 
# NO EDIT THIS FILE
#

# read mcso.conf
source /etc/mcso/mcso.conf

# Time
TIME=`date "+%Y%m%d_%H%M%S"`


# Function for start

func_master_session_start () {
    echo "Create master session for Minecraft Server"
    /usr/bin/tmux new -s $TMUX_MASTER_SESSION -d
    echo "Ready to Minecraft Server"
}

func_master_session_stop () {
    echo "Closing..."
    /usr/bin/tmux kill-session -t $TMUX_MASTER_SESSION
    echo "Shutdown master session for Minecraft Server"
}

# Main
# Select Process
case $1 in
    -mr ) func_master_session_start ;;
    -mt ) func_master_session_stop ;;
esac
