<!--
########################################################################
# Minecraft Complex Server Operator (MCSO)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                       README - Japanese                     
#
#
#
#                                               VERSION: 1.1.5
########################################################################
-->

# MCSO     : A management tool of Minecraft server

**MCSO**は、Minecraftサーバー(Bedrock / Java)を管理するための様々な機能を備えたコマンドラインツールです。

- **容易に展開** : ツールを実行するだけでMinecraftサーバーを簡単にインストール & アンインストール可能
- **豊富な管理機能** : サーバーの起動や停止、ステータスの確認、アップデートなどサーバーの管理面をコマンド一つで実行
- **バックアップ** : 自動もしくは手動で簡単バックアップ。サーバーのリストアもコマンドで可能
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

1) ms_applicationディレクトリにサーバーアプリケーション(BedrockまたはJava)、もしくはMCSOで作成されたフルバックアップのデータを配置してください。
- ファイル例: bedrock-server.X.XX.XX.XX.zip, server.jar, minecraft_XXXX_server_full_backup_XXXXXXXX_XXXXXX.tar.gz

2) ダウンロードしたMCSOのディレクトリ内にある`install_mcso.sh`を使用します。引数に実行ユーザー名、実行ユーザーのグループを追加してください。

```bash
./install_mcso.sh <USERNAME> <USERGOURP>
```

<br>

# Usage

サービスは`mcso`コマンドを通じて提供されます。<br><br>

- Minecraftサーバーを起動するには、エディションを指定して`mcso start`コマンドを使用します。<br>

例: Java Editionを起動する場合
```bash:
mcso start java
```
<br>

例: Bedrock Editionを起動する場合
```bash:
mcso start be
```
<br>

- Minecraftサーバーを停止するには、エディションを指定して`mcso stop`コマンドを使用します。<br>

例: Java Editionを停止する場合
```bash:
mcso stop java
```
<br>

例: Bedrock Editionを停止する場合
```bash:
mcso stop be
```
<br>

- Minecraftサーバーを再起動するには、エディションを指定して`mcso restart`コマンドを使用します。<br>

例: Java Editionを再起動する場合
```bash:
mcso restart java
```
<br>

例: Bedrock Editionを再起動する場合
```bash:
mcso restart be
```
<br>

- OSスタート後、Minecraftサーバーを自動で起動するには、エディションを指定して`mcso enable`コマンドを使用します。<br>

例: Java Editionを自動起動する場合
```bash:
mcso enable java
```
<br>

例: Bedrock Editionを自動起動する場合
```bash:
mcso enable be
```
<br>

### Function

- サーバーでMinecraftコマンドを実行するには、`mcso com`コマンドを使用します。
    - SESSION_NO: デフォルトは0
    - COMMAND: Minecraft内で使用可能なコマンド
```bash:
mcso com [be/java] SESSION_NO "COMMAND"
```
<br>

### Backup

- MCSOのバックアップは2種類の方法があります。
    - **FULL**: サーバーのすべてのデータをバックアップします。バックアップ時、サーバーは停止します。
    - **INSTANT**: サーバーの最低限のデータをバックアップします。バックアップ時、サーバーは停止しません。
        - `mcso create`コマンドでサポートされるバックアップデータは**FULL**のみです。

- 手動でバックアップするには`mcso backup`コマンドを使用します。
```bash:
mcso backup [be/java] [full/instant]
```

- またサーバーは定期的なバックアップを行います。バックアップはエディションごとに以下のルールに従い実行されます。
    - **FULL**
        - Bedrock: 週1回(月曜日) / 午前5時に1回実行
        - Java: 週1回(月曜日) / 午前5時30分に1回実行
    - **INSTANT**
        - Bedrock: 週6回(月曜日以外) / 午前5時に1回実行
        - Java: 週6回(月曜日以外) / 午前5時30分に1回実行
<br>

- フルバックアップデータをリストアするには`mcso restore`コマンドを使用します。
```bash:
mcso restore [be/java]
```

### Status

- MCSOのステータスを確認するには`mcso -s`コマンドを使用します。
```bash:
mcso -s
```

### Help

- `mcso`コマンドに関する詳細は、ヘルプを確認してください。
```bash:
mcso -h
```
<br>

# Upgrade

- Minecraftサーバーのバージョンをアップデートするには、`mcso -u`コマンドを使用します。

オンラインでアップデートするには`online`オプションを追加します。
```bash
mcso -u online
```
<br>

オフラインでアップデートするには、アプリケーションファイルが配置されている絶対パスを追加します。
```bash
mcso -u /tmp/SERVER_APPLICATION.jar
```
<br>

# Uninstallation

- MCSOをアンインストールするには、`uninstall_mcso.sh`を使用します。
    - 実行前にuninstall_mcso.shに記載のmcso.confの配置が正しいか確認してください。

```bash
./uninstall_mcso.sh
```

# Support

Contact: kokoroq

# License

MCSO is distributed under `MIT License`. See [LICENSE](https://github.com/kokoroq/mcso/blob/main/LICENSE)