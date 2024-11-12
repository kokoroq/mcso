#!/bin/bash
#

# Minecraft Complex Server Operator (MCSO)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
# This script is a uninstall script for MCSO
#
# !ATTENTION
# Make sure source of mbso.conf are correct before run
#

# Set default param
usercfm="back"

# read mcso.conf
source /etc/mcso/mcso.conf
source /etc/mcso/system_data.mcso

# Confirm to start uninstall process
clear
echo "******************************************************"
echo " Minecraft Complex Server Operator uninstall tool"
echo -e ""
echo " Version: $VERSION"
echo "******************************************************"
echo -e ""
echo "Start the uninstallation process"
echo "Do you really want to uninstall MBSO?"
read -p "(agree/back) Default is back: " usercfm

if [ "$usercfm" != "agree" ]; then
    echo "Abort the process"
    sleep 2
    exit 0
fi

# If the Minecraft BE Server is running, stop it
if [ $BE_TOOLS = "enable" ]; then
    online=`ps -ef | grep $MS_BE_SERVER | grep -v grep | wc -l` >/dev/null 2>&1
    if [ $online -ge 1 ]; then
        echo "Minecraft BE Server is running."
        echo "Stop the server..."
        $MCSO_DIR/stop_mcso.sh -b > /dev/null
        echo "Stop complete"
    fi
fi

# If the Minecraft Java Server is running, stop it
if [ $JAVA_TOOLS = "enable" ]; then
    online=`jps | grep $MS_JAVA_JAR | wc -l` >/dev/null 2>&1
    if [ $online -ge 1 ]; then
        echo "Minecraft Java Server is running."
        echo "Stop the server..."
        $MCSO_DIR/stop_mcso.sh -j > /dev/null
        echo "Stop complete"
    fi
fi

echo -e ""
echo "When the dialog box appears, please enter user password"

# Remove crontab schedule
crontab -l > rm.crontab
sudo sed -i -e'/backup_mcso.sh/d' rm.crontab
crontab rm.crontab
rm -f rm.crontab

# Uninstall files / 
echo "Remove MCSO packages"

test -f /usr/local/bin/mcso
if [ $? = 0 ]; then
    echo "- Remove /usr/local/bin/mcso"
    sudo rm -f /usr/local/bin/mcso
fi

test -f /etc/systemd/system/minecraft-be-server.service
if [ $? = 0 ]; then
    echo "- Remove /etc/systemd/system/minecraft-be-server.service"
    sudo rm -f /etc/systemd/system/minecraft-be-server.service
fi

test -f /etc/systemd/system/minecraft-java-server.service
if [ $? = 0 ]; then
    echo "- Remove /etc/systemd/system/minecraft-java-server.service"
    sudo rm -f /etc/systemd/system/minecraft-java-server.service
fi

test -f /etc/systemd/system/minecraft-master-session.service
if [ $? = 0 ]; then
    echo "- Remove /etc/systemd/system/minecraft-master-session.service"
    sudo rm -f /etc/systemd/system/minecraft-master-session.service
fi

test -d $MCSO_DIR
if [ $? = 0 ]; then
    echo "- Remove $MCSO_DIR"
    sudo rm -rf $MCSO_DIR
fi

test -d /etc/mcso/
if [ $? = 0 ]; then
    echo "- Remove /etc/mcso/"
    sudo rm -rf /etc/mcso/
fi

test -f /usr/share/bash-completion/completions/_mcso
if [ $? = 0 ]; then
    echo "- Remove /usr/share/bash-completion/completions/_mcso"
    sudo rm -f /usr/share/bash-completion/completions/_mcso
fi

echo "#############################"
echo "MCSO uninstall complete"