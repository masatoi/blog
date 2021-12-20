# Common Lispの実務で使っているAPIサーバの構成について

この記事では自分が実務でCommon Lispで開発しているWebシステムのAPIサーバの構成について解説する。

WebフレームワークUtopianには空のプロジェクトを作るコマンドが付属しているが、最低限の内容しか含まれないので、ある程度実用的なscaffoldとなるものが必要だと考えた。

具体的な例として[叩き台となるリポジトリ(masatoi/blog)](https://github.com/masatoi/blog)を作った。プロジェクト名は仮にblogとしたが、これをベースに開発する場合はsedなどでblogから好きなアプリケーション名に置き換えてほしい。

使っているツール群は以下のようなものになる(まだ含まれていないものもある)。
- Lisp処理系: [SBCL](http://www.sbcl.org/)
- 処理系マネージャ: [Roswell](https://github.com/roswell/roswell)
- Webサーバ: [woo](https://github.com/fukamachi/woo)
- HTTPクライアント: [Dexador](https://github.com/fukamachi/dexador)
- バージョン固定化ツール: [qlot](https://github.com/fukamachi/qlot)
- Webフレームワーク: [utopian](https://github.com/fukamachi/utopian)
- DB: Postgresql + [cl-dbi](https://github.com/fukamachi/cl-dbi)(DBインターフェース) + [mito](https://github.com/fukamachi/mito)(O/Rマッパー)
- テストフレームワーク: [Rove](https://github.com/fukamachi/rove)
- ロガー: [cl-fluent-logger](https://github.com/pokepay/cl-fluent-logger)

# サンプルプロジェクトの導入

まずRoswellを導入している必要がある。Homebrewが使える環境では以下のようにする。
その他の環境については[RoswellのGithub WikiのInstallの項](https://github.com/roswell/roswell/wiki/Installation)を参照するのがよい。

```
$ brew install roswell
```

rosコマンドが使えるようになったら最新のSBCLをインストールする。

```
$ ros install sbcl-bin
```

## 依存ライブラリのインストール

次にRoswellを使って最新のqlotをインストールする。

```
$ ros install fukamachi/qlot
```

これで`~/.roswell/bin`にパスが通っていればqlotコマンドが使えるようになっているはずだ。
サンプルプロジェクトをcloneし、`qlot install`することで`qlfile`と`qlfile.lock`に書かれたライブラリがプロジェクトローカルにインストールされる。

```
$ git clone git@github.com:masatoi/blog.git
$ cd blog
$ qlot install
```
これで`~/blog/.qlot`以下にプロジェクトローカルのQuicklispやGithubからライブラリがインストールされる。

qlfileを開くと、以下のような内容が記述されていることが分かる。`git`と書いてあるものはGithubからのインストールで、特定のブランチを指定することもできる。`ql`と書いてあるものはQuicklispからのインストールであることを意味する。

```
git utopian https://github.com/fukamachi/utopian
ql clack :latest
git apispec https://github.com/cxxxr/apispec :branch develop
git sanitized-params https://github.com/fukamachi/sanitized-params
```

## DBの用意

何らかの方法でPostgreSQLをインストールする。

```
$ sudo apt install postgresql
```

# qlfileを編集

qlfile
```
git utopian https://github.com/fukamachi/utopian
ql clack :latest
git apispec https://github.com/cxxxr/apispec :branch develop
```

# qlot exec でREPLを起動(M-x slime-qlot-exec)

# DBを作成

$ createuser -d blog
$ createdb blog

$ psql postgres

ALTER USER blog WITH PASSWORD 'blog';

psqlでユーザblog、パスワードblogでblogデータベースに接続できることを確認する。

```
psql -h localhost -U blog blog
Password for user blog: 
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.
```

この段階ではまだテーブルは無い

```
blog=> \d
Did not find any relations.
```

# テーブル定義

```lisp
(defpackage #:blog/models/user
  (:use #:cl
        #:mito)
  (:export #:user
           #:user-name))
(in-package #:blog/models/user)

(deftable user ()
  ((name :col-type (:varchar 256)
         :initform "")))
```

# DBマイグレーション

blog/config/environments/local でパスワードを設定しておく

```lisp
(defpackage #:blog/config/environments/local
  (:use #:cl))
(in-package #:blog/config/environments/local)

`(:databases
  ((:maindb . (:postgres
               :database-name "blog"
               :username "blog"
               :password "blog"))))
```

マイグレーションファイルを作る

$ .qlot/bin/utopian generate migration

Loading model files...Done    
CREATE TABLE "user" (
    "id" BIGSERIAL NOT NULL PRIMARY KEY,
    "name" VARCHAR(256) NOT NULL,
    "created_at" TIMESTAMPTZ,
    "updated_at" TIMESTAMPTZ
);
Successfully generated: db/migrations/20211121074550.up.sql

マイグレーションファイルを適用

$ .qlot/bin/utopian db migrate

Applying 'db/schema.sql'...
-> CREATE TABLE "user" (
    "id" BIGSERIAL NOT NULL PRIMARY KEY,
    "name" VARCHAR(256) NOT NULL,
    "created_at" TIMESTAMPTZ,
    "updated_at" TIMESTAMPTZ
);
-> CREATE TABLE IF NOT EXISTS "schema_migrations" (
    "version" VARCHAR(255) PRIMARY KEY,
    "applied_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
WARNING:
   PostgreSQL warning: relation "schema_migrations" already exists, skipping
Successfully updated to the version "20211121074550".

# サーバ開始
.qlot/bin/utopian server

# REPLから起動する場合
(defparameter *blog-app* (clack:clackup (merge-pathnames (asdf:system-source-directory :blog) #P"/app.lisp")))

main.lisp にユーティリティ追加(start-blog/stop-blog, connect-db)

# エンドポイント追加
controllerに関数追加
routes.lisp にパス記載

# viewsの定義
as-alistの導入
DONE

# repositoriesの導入
DONE

# apispec導入
TODO

# テストフレームワーク導入
TODO
roveのインストール

# ロガーの導入
TODO
fluentdの導入
cl-fluent-loggerのインストール

# より高速なサーバを導入する
wooのインストール
