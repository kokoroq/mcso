####################################################################

Minecraft Complex Server Operator (MCSO)
Copyright (c) 2023-2024 kokoroq. All rights reserved.

Version: 1.1.3

User Guide
						 * BE / Java support

####################################################################


・サポート
	- Ubuntu 22.04
	- Ubuntu 24.04
	- EL 8
	- EL 9



・インストール

1) [オプション] 実行ユーザーのsudo appをパスワードなしに変更してください。

	# visudo

	※一番下に下記を追記
	%<username> ALL=(ALL) NOPASSWD: ALL

2-A) [オプション/新規インストール] MCSOディレクトリ内にbedrock-server*.zip もしくはserver.jar のファイルを配置してください。
	※このオプションを行わない場合はセットアップスクリプト実行中に手動でコピーを行います。

2-B) [オプション/復元] restore_serverディレクトリ内に minecraft_be_server_full_backup*.tar.gz もしくはminecraft_java_server_full_backup*.tar.gz のファイルを配置してください。
	※このオプションを行わない場合はセットアップスクリプト実行中に手動でコピーを行います。
	※MCSOで作成したバックアップのみ有効

3) install_mbso.shを実行してください。
   引数に実行ユーザー名、実行ユーザーのグループを追加してください。

	# ./install_mcso.sh <USERNAME> <USERGROUP>



・Minecraft Serverの実行


- Minecraft BE Server 起動

	# mcso -r be
		-> BEサーバーの起動
	# mcso -r java
		-> Javaサーバーの起動

- Minecraft BE Server 停止

	# mcso -t be
		-> BEサーバーの停止
	# mcso -t java
		-> Javaサーバーの停止

- Minecraft BE Server 再起動

	# systemctl restart minecraft-be-server


- Minecraft Java Server 再起動

	# systemctl restart minecraft-java-server


・自動バックアップ

	フルバックアップ : 毎週月曜午前5時
	簡易バックアップ : 月曜以外の毎日午前5時


・手動バックアップ

	# mcso [-bb, -bj] full/instant 

		full : フルバックアップ
		instant : 簡易バックアップ

・バックアップデータをリストア (フルバックアップのみ対応)

	# mcso --restore [be / java]
		BE or Java Serverのアプリケーションを復元

・Minecraft Serverコンソールコマンドの実行

	# mcso [-cb, -cj] SESSION_NO COMMAND

		SESSION_NO : セッション番号(スタートは0)
		COMMAND : Minecraft Serverのコマンド内容

・Minecraft Serverアプリケーションで使用するCPU数を指定 (アプリケーションの再起動必須)

	# mcso -c [enable / disable]
		CPU Affinityの有効化/無効化

	# mcso -c [be / java] PROCESSOR_ID(s)
		BE or Java Serverで使用するCPU数を指定
		例) # mcso -c be 0,2,5-7

・現在のステータスを確認

	# mcso -s

・Minecraft server applicationをアップデート

	# mcso -u [online / FILE PATH]
		online : インターネットからダウンロードしてアップデート
		FILE PATH : ローカルにあるアップデートデータを使用してアップデート

・MCSO / Minecraft serverアプリケーションのバージョンを確認

	# mcso -v [server]
		-v : MCSOのバージョンを表示
		-v server : Minecraft BE / Java serverアプリケーションのバージョンを表示

・アンインストール

	# ./uninstall_mcso.sh

	※実行前にuninstall_mcso.shに記載のmcso.confの配置が正しいか確認してください。
