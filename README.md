# Sakura CLI

Sakura CLI は, [さくらのレンタルサーバー](http://www.sakura.ne.jp/)のコントロールパネルをコマンドラインから制御するためのツールです.

:construction: このバージョンでは, ライト/スタンダード/プレミアムに共通する **メールアドレス管理** 機能のみサポートします

## セットアップ

Sakura CLI をインストールします.

```zsh
gem install sakura-cli
```

Sakura CLI は[ChromeDriver](https://chromedriver.chromium.org/downloads) に依存しています.
お使いのOS に合った方法でインストールしてください.

Mac の場合は

```zsh
brew install chromedriver
```

でもインストールできます.

### 環境設定

ログイン情報を環境変数に設定します.

```zsh
export SAKURA_DOMAIN='example.com'
export SAKURA_PASSWD='your_password'
```

[dotenv](https://github.com/bkeepers/dotenv) を使うと便利かもしれません.

```zsh
# ~/.sakura.env (dotenv の場合)

SAKURA_DOMAIN='example.com'
SAKURA_PASSWD='your_password'
```

場合によっては[direnv](https://github.com/zimbatm/direnv) もいいでしょう.


## 使いかた

```sakura help``` や ```sakura mail help``` コマンドでヘルプが表示できます.

```zsh
$ sakura help
Commands:
  sakura help [COMMAND]  # Describe available commands or one specific command
  sakura mail            # Manage mail addresses

$ sakura mail help
Commands:
  sakura mail create LOCAL_PART [PASSWORD]             # Create a mail address
  sakura mail delete LOCAL_PART                        # Delete a mail address
  sakura mail forward LOCAL_PART [{add|remove} EMAIL]  # Add, remove or show mail address(es) to forward
  sakura mail help [COMMAND]                           # Describe subcommands or one specific subcommand
  sakura mail keep LOCAL_PART [enable|disable]         # Switch keep or flush mails
  sakura mail list                                     # List all mail addresses of the domain
  sakura mail password LOCAL_PART [PASSWORD]           # Update password of a mail address
  sakura mail quota LOCAL_PART [VALUE]                 # Update or show quota of a mail address
  sakura mail scan LOCAL_PART [enable|disable]         # Switch virus scan
  sakura mail show LOCAL_PART                          # Display information about a mail address
```

### メールアドレス一覧

```sakura mail list``` コマンドで, メールアドレス一覧とその概要を表示できます.

```zsh
$ sakura mail list
# domain: example.com
address                     usage /     quota  (  %)
---------------------------------------------------------
dummy                       893KB /     200MB  ( 0%)
dummy001                   19.5MB /     200MB  ( 9%)
dummy002                   11.4MB /     200MB  ( 5%)
postmaster                 9.75MB /     200MB  ( 4%)
```

### メールアドレス詳細

```sakura mail show``` コマンドで, あるメールアドレスの詳細を表示できます.

```zsh
$ sakura mail show dummy
usage / quota: 893KB / 200MB  ( 0%)
forward_to:    foo@example.com
keep mail:     true
virus scan:    false
spam filter:   disable
```

### メールアドレス作成

```sakura mail create``` コマンドで, メールアドレスを作成できます.

```zsh
$ sakura mail create dummy
password?
password(confirm)?
```

コマンド引数に初期パスワードを指定することもできます.

### メールアドレス削除

```sakura mail delete``` コマンドで, メールアドレスを削除できます.

### クォータ表示・変更

```sakura mail quota``` コマンドで, 現在のクォータを表示・変更できます.

```zsh
$ sakura mail quota dummy     # 現在のクォータを表示
200MB

$ sakura mail quota dummy 300 # 300MB に変更
```

変更する場合, 単位はMB です.

### パスワード変更

```sakura mail password``` コマンドで, パスワードをリセットできます.

```zsh
$ sakura mail password dummy
password?
password(confirm)?
```

コマンド引数に初期パスワードを指定することもできます.

### メール転送

```sakura mail forward``` コマンドで, 転送先リストを表示・編集できます.

```zsh
$ sakura mail forward dummy                         # 転送先リストを表示
foo@example.com
$ sakura mail forward dummy add bar@example.com     # 転送先に追加
$ sakura mail forward dummy remove bar@example.com  # 転送先から削除
```

```sakura mail keep``` コマンドで, メールをメールボックスに残すか/転送専用にするか の設定を表示・変更できます.

```zsh
$ sakura mail keep dummy          # 設定を表示
true
$ sakura mail keep dummy disable  # メールボックスに残す
```

### ウィルスチェック

```sakura mail scan``` コマンドで, ウィルスチェックの設定を表示・変更できます.

```zsh
$ sakura mail scan dummy         # ウィルスチェックの設定を表示
false
$ sakura mail scan dummy enable  # 有効にする
```

## その他

### dotenv から起動

```~/.sakura.env``` に環境変数一覧がある場合

```zsh
dotenv -f ~/.sakura.env sakura
```

のように実行します.


## Copyright and License

Copyright (c) 2015-2025 Shintaro Kojima. Code released under the [MIT license](LICENSE).
