<!--
########################################################################
# Minecraft Complex Server Operator (MCSO)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                       README - English                      
#
#
#
#                                               VERSION: 1.1.5
########################################################################
-->

# MCSO     : A management tool of Minecraft server

**MCSO** is a command line tool with various functions to manage a Minecraft server (Bedrock / Java)

- **Easy deployment** : Easily install & uninstall Minecraft server by simply running the tool
- **Many management features** : Start and Stop server, check status, etc. with a single command
- **Simple Backup** : Automatic or Manual backup. Of course, servers can also be restored
<br>

# Requirement

### Operating System
- Linux
    - The list is confirmed OS
        - Ubuntu 22.04
        - Ubuntu 24.04

### Packages :
- unzip
- wget
- cron
<br>

# Installation

1) Copy the server application (Bedrock or Java) or the full backup data created by MCSO to the 'ms_app' directory.
- e.g. bedrock-server.X.XX.XX.XX.zip, server.jar, minecraft_XXXX_server_full_backup_XXXXXXXX_XXXXXX.tar.gz

2) Use `install_mcso.sh` in the downloaded MCSOC directory. Add the executing user name and the executing user group as arguments.

```bash
./install_mcso.sh <USERNAME> <USERGOURP>
```
<br>

# Usage

Services are provided through `mcso` command.<br><br>

- To start the Minecraft server, use the `mcso start` command with the edition name. <br>

e.g. If you want to start Java Edition
```bash:
mcso start java
```
<br>

e.g. If you want to start Bedrock Edition
```bash:
mcso start be
```
<br>

- To stop the Minecraft server, use the `mcso stop` command with the edition name. <br>

e.g. If you want to stop Java Edition
```bash:
mcso stop java
```
<br>

e.g. If you want to stop Bedrock Edition
```bash:
mcso stop be
```
<br>

- To restart the Minecraft server, use the `mcso restart` command with the edition name. <br>

e.g. If you want to restart Java Edition
```bash:
mcso restart java
```
<br>

e.g. If you want to restart Bedrock Edition
```bash:
mcso restart be
```
<br>

- To automatically start the Minecraft server after OS start, use the `mcso enable` command with the edition name. <br>

e.g. If you want to auto-start Java Edition
```bash:
mcso enable java
```
<br>

e.g. If you want to auto-start Bedrock Edition
```bash:
mcso enable be
```
<br>

### Function

- To run Minecraft commands on the server, use the `mcso com` command.
    - SESSION_NO: Default is 0
    - COMMAND: Console commands available in Minecraft
```bash:
mcso com [be/java] SESSION_NO "COMMAND"
```
<br>

### Backup

- There are two ways to backup by MCSO.
    - **FULL**: Backup all data on the server. During backup, the server is stopped.
    - **INSTANT**: Backup minimal data on the server. During backup, the server is not stopped.
        - Backup data supported by `mcso create` is only for **FULL**.


- To backup manually, use the `mcso backup` command.
```bash:
mcso backup [be/java] [full/instant]
```

- Servers are also scheduled backup.Backup will begin by the following rules, depending on the edition.
    - **FULL**
        - Bedrock: Once a week (Monday) / run at 5:00 am.
        - Java: Once a week (Monday) / run at 5:30 am.
    - **INSTANT**
        - Bedrock: Six times per week (Except Monday) / run at 5:00 am.
        - Java: Six times per week (Except Monday) / run at 5:30 am.
<br>

- To restore full backup data, use the `mcso restore` command.
```bash:
mcso restore [be/java]
```

### Status

- To check the status of MCSO, use the `mcso -s` command.
```bash:
mcso -s
```

### Help

- For more information on the `mcsoc` command, check the help.
```bash:
mcsoc -h
```
<br>

# Update of Bedrock or Java

- To upgrade the Minecraft server version, use `mcso -u` command.

Add the `online` option to update online.
```bash
mcso -u online
```
<br>

Add the absolute path where the application files are located to update offline, 
```bash
mcso -u /tmp/SERVER_APPLICATION.jar
```
<br>

# Uninstallation

- To uninstall MCSO, use `uninstall_mcso.sh`.
    - Please make sure that the mcso.conf written in uninstall_mcso.sh is located correctly.
```bash
./uninstall_mcso.sh
```

# Language

 **[Japanese - 日本語](https://github.com/kokoroq/mcso/blob/main/docs/README_ja.md)**

# Support

Contact: kokoroq

# License

MCSO is distributed under `MIT License`. See [LICENSE](https://github.com/kokoroq/mcso/blob/main/LICENSE)