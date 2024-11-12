#!/bin/bash

################################################################
#         Minecraft Complex Server Operator (MCSO)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
################################################################
#
# This script is a setup script for MCSO
#
#------#
# USAGE
#------#
#
# To install MCSO
# ./install_mcso.sh [USERNAME] [USERGROUP]
#


# Username / Usergroup
if [ $# -ne 2 ]; then
    echo "Invalid arguments"
    echo "To install, see README.md"
    exit 1
fi

# read mcso.conf
source ./packages/etc/mcso.conf

#---------------------------------------------------------------#
# VARS
#---------------------------------------------------------------#

# Initial args
USERNAME=$1
USERGROUP=$2

# mcso installer directory path
mcso_installer_path=$(cd $(dirname $0);pwd)

# Flag to install both editions
# 0 = install be OR java
# 1 = install be AND java 
both_flag=0
#---------------------------------------------------------------#



# Setup funtion
#################################################################
# Bedrock Edition
#################################################################
func_be_setup () {
    echo "Setup now for BE..."

    # Create directory
    test -d $MS_BE_DIR
    if [ $? = 1 ];then sudo mkdir -p $MS_BE_DIR;fi
    sudo chown -R $1:$2 $MS_BE_DIR

    test -d $MCSO_DIR
    if [ $? = 1 ];then sudo mkdir -p $MCSO_DIR;fi
    sudo chown -R $1:$2 $MCSO_DIR

    test -d $FULL_BACKUP_BE_DIR
    if [ $? = 1 ];then sudo mkdir -p $FULL_BACKUP_BE_DIR;fi
    test -d $INSTANT_BACKUP_BE_DIR
    if [ $? = 1 ];then sudo mkdir -p $INSTANT_BACKUP_BE_DIR;fi
    sudo chown -R $1:$2 $BACKUP_BE_DIR

    test -d $LOG_BE_DIR
    if [ $? = 1 ];then sudo mkdir -p $LOG_BE_DIR;fi
    sudo chown -R $1:$2 $LOG_BE_DIR

    test -d /etc/mcso
    if [ $? = 1 ];then sudo mkdir -p /etc/mcso;fi
    sudo chown -R $1:$2 /etc/mcso

    # install require packages
    #   - unzip
    #   - tmux
    #   - tar
    #   - cron


    pkgs_count=0
    echo "Is your operating system Ubuntu or RHEL compatible(EL)?"
    read -p "(ubuntu/el) Default is ubuntu: " selectos

    if [ "$selectos" = "ubuntu" ] || [ "$selectos" = "" ]; then
        # Ubuntu
        pkgs=("unzip" "tmux" "tar" "cron" "wget" "__EOF__")
        export DEBIAN_FRONTEND=noninteractive
        sudo apt-get update >/dev/null
        while [ ${pkgs[$pkgs_count]} != "__EOF__" ]
        do
            pkgline=`dpkg -l ${pkgs[$pkgs_count]} | grep ${pkgs[$pkgs_count]} | wc -l` >/dev/null
            if [ $pkgline -eq 0 ]; then
                if [ ${#pkgs_b_inst[*]} -eq 0 ]; then
                    pkgs_b_inst+="cron ${pkgs[${pkgs_count}]}"
                else
                    pkgs_b_inst+=" ${pkgs[${pkgs_count}]}"
                fi
            fi
            pkgs_count=`expr $pkgs_count + 1`
        done
        sudo apt-get -y install $pkgs_b_inst >/dev/null
    elif [ "$selectos" = "el" ]; then
        # EL
        pkgs=("unzip" "tmux" "tar" "crontabs" "wget" "__EOF__")
        sudo dnf update >/dev/null
        while [ ${pkgs[$pkgs_count]} != "__EOF__" ]
        do
            pkgline=`dnf list installed | grep ${pkgs[$pkgs_count]} | wc -l`
            if [ $pkgline -eq 0 ]; then
                if [ $pkgs_count -eq 0 ]; then
                    pkgs_b_inst+="${pkgs[${pkgs_count}]}"
                else
                    pkgs_b_inst+=" ${pkgs[${pkgs_count}]}"
                fi
            fi
            pkgs_count=`expr $pkgs_count + 1`
        done
        sudo dnf -y install $pkgs_b_inst >/dev/null
    else
        echo "Invalid word, Please retry to run"
        exit 1
    fi

    # Setting for backup
    crontab -l > setup.crontab
    echo "0 5 * * 1 $MCSO_DIR/backup_mcso.sh -fb" >> setup.crontab
    echo "0 5 * * 2-7 $MCSO_DIR/backup_mcso.sh -ib" >> setup.crontab
    crontab setup.crontab
    rm -f setup.crontab


    # Install MCSO
    if [ ! -e /etc/systemd/system/minecraft-java-server.service ]; then
        sudo cp -p ./packages/bin/mcso /usr/local/bin/
        sudo chmod +x /usr/local/bin/mcso
        sudo cp -p ./packages/scripts/start_mcso.sh $MCSO_DIR
        sudo chmod +x $MCSO_DIR/start_mcso.sh
        sudo chown $1:$2 $MCSO_DIR/start_mcso.sh
        sudo cp -p ./packages/scripts/stop_mcso.sh $MCSO_DIR
        sudo chmod +x $MCSO_DIR/stop_mcso.sh
        sudo chown $1:$2 $MCSO_DIR/stop_mcso.sh
        sudo cp -p ./packages/scripts/backup_mcso.sh $MCSO_DIR
        sudo chmod +x $MCSO_DIR/backup_mcso.sh
        sudo chown $1:$2 $MCSO_DIR/backup_mcso.sh
        sudo cp -p ./packages/scripts/update_mcso.sh $MCSO_DIR
        sudo chmod +x $MCSO_DIR/update_mcso.sh
        sudo chown $1:$2 $MCSO_DIR/update_mcso.sh
        sudo cp -p ./packages/etc/mcso.conf /etc/mcso/
        sudo chown $1:$2 /etc/mcso/mcso.conf
        sudo cp -p ./packages/etc/system_data.mcso /etc/mcso/
        sudo chown $1:$2 /etc/mcso/system_data.mcso
        sudo cp ./packages/service/minecraft-master-session.service /etc/systemd/system/
        sudo chmod 664 /etc/systemd/system/minecraft-master-session.service
        sudo chown root:root /etc/systemd/system/minecraft-master-session.service
        sudo cp -p ./packages/scripts/system_mcso.sh $MCSO_DIR
        sudo chmod +x $MCSO_DIR/system_mcso.sh
        sudo chown $1:$2 $MCSO_DIR/system_mcso.sh
        sudo cp -p ./packages/etc/_mcso /usr/share/bash-completion/completions/
    fi

    sudo cp ./packages/service/minecraft-be-server.service /etc/systemd/system/
    sudo chmod 664 /etc/systemd/system/minecraft-be-server.service
    sudo chown root:root /etc/systemd/system/minecraft-be-server.service


    # Add username and groupname for unit file
    sudo sed -i -e "8i User=$1" /etc/systemd/system/minecraft-be-server.service
    sudo sed -i -e "9i Group=$2" /etc/systemd/system/minecraft-be-server.service
    if [ ! -e /etc/systemd/system/minecraft-java-server.service ]; then
        sudo sed -i -e "7i User=$1" /etc/systemd/system/minecraft-master-session.service
        sudo sed -i -e "8i Group=$2" /etc/systemd/system/minecraft-master-session.service
    fi

    # Set environment variable in the mbso username and usergroup
    if [ ! -e /etc/systemd/system/minecraft-java-server.service ]; then
        sudo sed -i -e "9i USERNAME=\"$1\"" /etc/mcso/mcso.conf
        sudo sed -i -e "12i USERGROUP=\"$2\"" /etc/mcso/mcso.conf
    fi

    # Set to enable BE tools
    sed -i -e 's/BE_TOOLS="disable"/BE_TOOLS="enable"/' /etc/mcso/system_data.mcso

    # Select new install or restore
    if [ -e ./ms_app/*.zip ]; then
        cp ./ms_app/*.zip $MS_BE_DIR
        for filenm in $MS_BE_DIR/*.zip
        do
            if [ -e $filenm ]; then
                tmp_be_name=`basename $filenm`
            fi
        done
        sudo chown $1:$2 $MS_BE_DIR/$tmp_be_name
        unzip $MS_BE_DIR/$tmp_be_name -d $MS_BE_DIR >/dev/null
        
        # Create application version infomation file
        echo $tmp_be_name | sed -r "s/bedrock-server-(.*)\.zip$/\1/" > $MS_BE_DIR/be_version.txt
    else
        echo "Do you want to install a new minecraft server or restore an existing one?"
        echo "  1 - NEW INSTALLATION"
        echo "  2 - RESTORE THE EXISTING SERVER"
        read -p "Enter the number you chose> " select_newexi
        if [ $select_newexi -eq 1 ]; then
            echo "Please copy the bedrock-server~.zip of Minecraft BE Server to $MS_BE_DIR"
            read -p "When you are done, press ENTER:" wait_enter
            unzip $tmp_be_name -d $MS_BE_DIR >/dev/null
            for filenm in $MS_BE_DIR/bedrock-server-*.zip
            do
                if [ -e $filenm ]; then
                    tmp_be_name=`basename $filenm`
                fi
            done
            # Create application version infomation file
            echo $tmp_be_name | sed -r "s/bedrock-server-(.*)\.zip$/\1/" > $MS_BE_DIR/be_version.txt
            
        elif [ $select_newexi -eq 2 ]; then
            if [ -e ./ms_app/minecraft_be_server_full_backup_*.tar.gz ]; then
                echo "Restore application..."
                rm -rf $MS_BE_DIR/*
                cp ./ms_app/minecraft_be_server_full_backup_*.tar.gz $MS_BE_DIR
                tar -zxvf $MS_BE_DIR/minecraft_be_server_full_backup_*.tar.gz -C $MS_BE_DIR >/dev/null
                mv $MS_BE_DIR/minecraft_be_server_full_backup_*/* $MS_BE_DIR
                rm -rf $MS_BE_DIR/minecraft_be_server_full_backup_*
                sudo chown -R $1:$2 $MS_BE_DIR/
            else
                echo "Please copy the restore file of Minecraft BE Server to mcso.X.X.X-release/ms_app/"
                read -p "When you are done, press ENTER:" wait_enter
                echo "Restore application..."
                rm -rf $MS_BE_DIR/*
                cp ./ms_app/minecraft_be_server_full_backup_*.tar.gz $MS_BE_DIR
                tar -zxvf $MS_BE_DIR/minecraft_be_server_full_backup_*.tar.gz -C $MS_BE_DIR >/dev/null
                mv $MS_BE_DIR/minecraft_be_server_full_backup_*/* $MS_BE_DIR
                rm -rf $MS_BE_DIR/minecraft_be_server_full_backup_*
                sudo chown -R $1:$2 $MS_BE_DIR/
            fi
        else
            echo "Invalid option, Please retry to run"
            exit 1
        fi
    fi

    echo "Setup of BE is complete"
    echo "------------------------------------------------------"
}

#################################################################
# Java Edition
#################################################################

func_java_setup () {
    echo "Setup now for JavaE..."

    # Create directory
    test -d $MS_JAVA_DIR
    if [ $? = 1 ];then sudo mkdir -p $MS_JAVA_DIR;fi
    sudo chown -R $1:$2 $MS_JAVA_DIR

    test -d $MCSO_DIR
    if [ $? = 1 ];then sudo mkdir -p $MCSO_DIR;fi
    sudo chown -R $1:$2 $MCSO_DIR

    test -d $FULL_BACKUP_JAVA_DIR
    if [ $? = 1 ];then sudo mkdir -p $FULL_BACKUP_JAVA_DIR;fi
    test -d $INSTANT_BACKUP_JAVA_DIR
    if [ $? = 1 ];then sudo mkdir -p $INSTANT_BACKUP_JAVA_DIR;fi
    sudo chown -R $1:$2 $BACKUP_JAVA_DIR

    test -d $LOG_JAVA_DIR
    if [ $? = 1 ];then sudo mkdir -p $LOG_JAVA_DIR;fi
    sudo chown -R $1:$2 $LOG_JAVA_DIR

    test -d /etc/mcso
    if [ $? = 1 ];then sudo mkdir -p /etc/mcso;fi
    sudo chown -R $1:$2 /etc/mcso

    # install require packages
    #   - java
    #   - tmux
    #   - wget
    #   - cron

    if [ $both_flag -eq 0 ]; then
        selectos="ubuntu"
        echo "Is your operating system Ubuntu or RHEL compatible(EL)?"
        read -p "(ubuntu/el) Default is ubuntu: " selectos
    fi

    pkgs_count=0
    if [ "$selectos" = "ubuntu" ] || [ "$selectos" = "" ]; then
        # Ubuntu
        pkgs=("openjdk-21-jre-headless" "cron" "tmux" "wget" "__EOF__")
        export DEBIAN_FRONTEND=noninteractive
        sudo apt-get update >/dev/null
        while [ ${pkgs[$pkgs_count]} != "__EOF__" ]
        do
            pkgline=`dpkg -l ${pkgs[$pkgs_count]} | grep ${pkgs[$pkgs_count]} | wc -l` >/dev/null
            if [ $pkgline -eq 0 ]; then
                if [ ${#pkgs_j_inst[*]} -eq 0 ]; then
                    pkgs_j_inst+="cron ${pkgs[${pkgs_count}]}"
                else
                    pkgs_j_inst+=" ${pkgs[${pkgs_count}]}"
                fi
            fi
            pkgs_count=`expr $pkgs_count + 1`
        done
        sudo apt-get -y install $pkgs_j_inst >/dev/null
    elif [ "$selectos" = "el" ]; then
        # EL
        pkgs=("java-21-openjdk" "java-21-openjdk-devel" "tmux" "crontabs" "wget" "__EOF__")
        sudo dnf update >/dev/null
        while [ ${pkgs[$pkgs_count]} != "__EOF__" ]
        do
            pkgline=`dnf list installed | grep ${pkgs[$pkgs_count]} | wc -l`
            if [ $pkgline -eq 0 ]; then
                if [ $pkgs_count -eq 0 ]; then
                    pkgs_j_inst+="${pkgs[${pkgs_count}]}"
                else
                    pkgs_j_inst+=" ${pkgs[${pkgs_count}]}"
                fi
            fi
            pkgs_count=`expr $pkgs_count + 1`
        done
        sudo dnf -y install $pkgs_j_inst >/dev/null
    else
        echo "Invalid word, Please retry to run"
        exit 1
    fi

    # Setting for backup
    crontab -l > setup.crontab
    echo "30 5 * * 1 $MCSO_DIR/backup_mcso.sh -fj" >> setup.crontab
    echo "30 5 * * 2-7 $MCSO_DIR/backup_mcso.sh -ij" >> setup.crontab
    crontab setup.crontab
    rm -f setup.crontab

    # Install MCSO
    if [ ! -e /etc/systemd/system/minecraft-be-server.service ]; then
        sudo cp -p ./packages/bin/mcso /usr/local/bin/
        sudo chmod +x /usr/local/bin/mcso
        sudo cp -p ./packages/scripts/start_mcso.sh $MCSO_DIR
        sudo chmod +x $MCSO_DIR/start_mcso.sh
        sudo chown $1:$2 $MCSO_DIR/start_mcso.sh
        sudo cp -p ./packages/scripts/stop_mcso.sh $MCSO_DIR
        sudo chmod +x $MCSO_DIR/stop_mcso.sh
        sudo chown $1:$2 $MCSO_DIR/stop_mcso.sh
        sudo cp -p ./packages/scripts/backup_mcso.sh $MCSO_DIR
        sudo chmod +x $MCSO_DIR/backup_mcso.sh
        sudo chown $1:$2 $MCSO_DIR/backup_mcso.sh
        sudo cp -p ./packages/scripts/update_mcso.sh $MCSO_DIR
        sudo chmod +x $MCSO_DIR/update_mcso.sh
        sudo chown $1:$2 $MCSO_DIR/update_mcso.sh
        sudo cp -p ./packages/etc/mcso.conf /etc/mcso/
        sudo chown $1:$2 /etc/mcso/mcso.conf
        sudo cp -p ./packages/etc/system_data.mcso /etc/mcso/
        sudo chown $1:$2 /etc/mcso/system_data.mcso
        sudo cp ./packages/service/minecraft-master-session.service /etc/systemd/system/
        sudo chmod 664 /etc/systemd/system/minecraft-master-session.service
        sudo chown root:root /etc/systemd/system/minecraft-master-session.service
        sudo cp -p ./packages/scripts/system_mcso.sh $MCSO_DIR
        sudo chmod +x $MCSO_DIR/system_mcso.sh
        sudo chown $1:$2 $MCSO_DIR/system_mcso.sh
        sudo cp -p ./packages/etc/_mcso /usr/share/bash-completion/completions/
    fi

    sudo cp ./packages/service/minecraft-java-server.service /etc/systemd/system/
    sudo chmod 664 /etc/systemd/system/minecraft-java-server.service
    sudo chown root:root /etc/systemd/system/minecraft-java-server.service

    # Add username and groupname for unit file
    sudo sed -i -e "8i User=$1" /etc/systemd/system/minecraft-java-server.service
    sudo sed -i -e "9i Group=$2" /etc/systemd/system/minecraft-java-server.service
    if [ ! -e /etc/systemd/system/minecraft-be-server.service ]; then
        sudo sed -i -e "7i User=$1" /etc/systemd/system/minecraft-master-session.service
        sudo sed -i -e "8i Group=$2" /etc/systemd/system/minecraft-master-session.service
    fi

    # Set to enable Java tools
    sed -i -e 's/JAVA_TOOLS="disable"/JAVA_TOOLS="enable"/' /etc/mcso/system_data.mcso

    # Select new install or restore
    if [ -e ./ms_app/*.jar ]; then
        cp ./ms_app/*.jar $MS_JAVA_DIR
        for filenm in $MS_JAVA_DIR/*.jar
        do
            if [ -e $filenm ]; then
                tmp_jar_name=`basename $filenm`
            fi
        done
        sudo chown $1:$2 $MS_JAVA_DIR/$tmp_jar_name
        cd $MS_JAVA_DIR
        /usr/bin/java -Xmx1024M -Xms1024M -jar $tmp_jar_name nogui >/dev/null
        sed -i -e "s/false/true/" $MS_JAVA_DIR/eula.txt
        cd $mcso_installer_path
    else
        echo "Do you want to install a new minecraft server or restore an existing one?"
        echo "  1 - NEW INSTALLATION"
        echo "  2 - RESTORE THE EXISTING SERVER"
        read -p "Enter the number you chose> " select_newexi
        # New installation
        if [ $select_newexi -eq 1 ]; then
            echo "Please copy the ~.jar of Minecraft Java Server to $MS_JAVA_DIR"
            read -p "When you are done, press ENTER:" wait_enter
            for filenm in $MS_JAVA_DIR/*.jar
            do
                if [ -e $filenm ]; then
                    tmp_jar_name=`basename $filenm`
                fi
            done
            cd $MS_JAVA_DIR
            /usr/bin/java -Xmx1024M -Xms1024M -jar $tmp_jar_name nogui >/dev/null
            sed -i -e "s/false/true/" $MS_JAVA_DIR/eula.txt
            cd $mcso_installer_path
        # Restore
        elif [ $select_newexi -eq 2 ]; then
            if [ -e ./ms_app/minecraft_java_server_full_backup_*.tar.gz ]; then
                echo "Restore application..."
                rm -rf $MS_JAVA_DIR/*
                cp ./ms_app/minecraft_java_server_full_backup_*.tar.gz $MS_JAVA_DIR
                tar -zxvf $MS_JAVA_DIR/minecraft_java_server_full_backup_*.tar.gz -C $MS_JAVA_DIR >/dev/null
                mv $MS_JAVA_DIR/minecraft_java_server_full_backup_*/* $MS_JAVA_DIR
                rm -rf $MS_JAVA_DIR/minecraft_java_server_full_backup_*
                sudo chown -R $1:$2 $MS_JAVA_DIR/
                for filenm in $MS_JAVA_DIR/*.jar
                do
                    if [ -e $filenm ]; then
                        tmp_jar_name=`basename $filenm`
                    fi
                done
            else
                echo "Please copy the restore file of Minecraft Java Server to mcso.X.X.X-release/ms_app/"
                read -p "When you are done, press ENTER:" wait_enter
                echo "Restore application..."
                rm -rf $MS_JAVA_DIR/*
                cp ./ms_app/minecraft_java_server_full_backup_*.tar.gz $MS_JAVA_DIR
                tar -zxvf $MS_JAVA_DIR/minecraft_java_server_full_backup_*.tar.gz -C $MS_JAVA_DIR >/dev/null
                mv $MS_JAVA_DIR/minecraft_java_server_full_backup_*/* $MS_JAVA_DIR
                rm -rf $MS_JAVA_DIR/minecraft_java_server_full_backup_*
                sudo chown -R $1:$2 $MS_JAVA_DIR/
                for filenm in $MS_JAVA_DIR/*.jar
                do
                    if [ -e $filenm ]; then
                        tmp_jar_name=`basename $filenm`
                    fi
                done
            fi
        else
            echo "Invalid option, Please retry to run"
            exit 1
        fi
    fi

    # Set environment variable in the mcso username, usergroup and jar name
    if [ ! -e /etc/systemd/system/minecraft-be-server.service ]; then
        sudo sed -i -e "9i USERNAME=\"$1\"" /etc/mcso/mcso.conf
        sudo sed -i -e "12i USERGROUP=\"$2\"" /etc/mcso/mcso.conf
    fi
    sudo sed -i -e "24i MS_JAVA_JAR=\"\$MS_JAVA_DIR/$tmp_jar_name\"" /etc/mcso/mcso.conf

    # Create application version infomation file
    echo $tmp_jar_name | sed  -r "s/minecraft_server\.(.*)\.jar$/\1/" > $MS_JAVA_DIR/java_version.txt
    
    echo "Setup of Java Edition is complete"
    echo "------------------------------------------------------"
}

# Welcome message
clear
echo "******************************************************"
echo " Welcome to Minecraft Complex Server Operator (MCSO)!"
echo -e ""
echo " Version: $VERSION"
echo "******************************************************"
echo -e ""
echo "USERNAME:     $USERNAME"
echo "USERGROUP:    $USERGROUP"
echo -e ""
echo "Which edition(s) do you want to set up"
echo "    1)  Bedrock Edition"
echo "    2)  Java Edition"
echo "    3)  Both Editions"
echo "    0)  Exit"
read -p "Select a number: " selstart
case "$selstart" in
    1 ) func_be_setup $USERNAME $USERGROUP ;;
    2 ) func_java_setup $USERNAME $USERGROUP ;;
    3 ) both_flag=1; func_be_setup $USERNAME $USERGROUP; func_java_setup $USERNAME $USERGROUP ;;
    * ) echo "Abort setup"; exit 0 ;;
esac