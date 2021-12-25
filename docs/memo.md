# Common Lispの実務で使っているAPIサーバの構成について

この記事では自分が実務でCommon Lispで開発しているWebシステムのAPIサーバの構成について解説する。

WebフレームワークUtopianには空のプロジェクトを作るコマンドが付属しているが、それによりできるプロジェクトには最低限の内容しか含まれないので、ある程度実用的なscaffoldとなるものが必要だと考えた。

具体的な例として[叩き台となるリポジトリ(masatoi/blog)](https://github.com/masatoi/blog) を作った。プロジェクト名は仮にblogとしたが、これをベースに開発する場合はsedなどでblogから好きなアプリケーション名に置き換えてほしい。

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

### qlfileについて

qlfileを開くと、以下のような内容が記述されていることが分かる。`git`と書いてあるものはGithubからのインストールで、特定のブランチを指定することもできる。`ql`と書いてあるものはQuicklispからのインストールであることを意味する。

```
git utopian https://github.com/fukamachi/utopian
ql clack :latest
git apispec https://github.com/cxxxr/apispec :branch develop
```

`qlot install`の初回実行時に`qlfile.lock`が生成され、実際にインストールされた各ライブラリのバージョンが記録される。これにより依存ライブラリのバージョンが固定化される。
`qlfile.lock`を編集して再度`qlot install`を実行するとバージョンを変更したライブラリのみ再インストールされる。

`qlfile.lock`の記載例。Quicklispからインストールする場合は、どの時点のQuicklispリポジトリからインストールするかを指定できる。Githubからインストールする場合は特定のコミットのハッシュ値を指定できる。
```
("quicklisp" .
 (:class qlot/source/dist:source-dist
  :initargs (:distribution "http://beta.quicklisp.org/dist/quicklisp.txt" :%version :latest)
  :version "2021-10-21"))
("utopian" .
 (:class qlot/source/git:source-git
  :initargs (:remote-url "https://github.com/fukamachi/utopian")
  :version "git-c6ad73d5a9bba245ad7b747e7764c94e3ea0ba23"))
("clack" .
 (:class qlot/source/ql:source-ql
  :initargs (:%version :latest)
  :version "ql-2021-10-21"))
("apispec" .
 (:class qlot/source/git:source-git
  :initargs (:remote-url "https://github.com/cxxxr/apispec" :branch "develop")
  :version "git-0f93705b8d75a555d69bce79dced53a1a73f9297"))
```

# qlot exec でREPLを起動する

qlotでインストールしたライブラリはプロジェクトローカルにあるので、それらをLisp処理系から読み込むためには`qlot exec`を使う。これは続くコマンドで起動されるLisp処理系のライブラリ参照パスをプロジェクトローカルに向ける効果がある。
例えば開発環境としてlemを使う場合は、

```
$ qlot exec lem
```

としてlemを起動し、`M-x slime`としてSBCLを起動した後に

```lisp
(ql:quickload :blog)
```

とすると依存ライブラリを含めシステム全体をロードできる。

Emacsを使っている場合は、

```elisp
(defun slime-qlot-exec (directory)
  (interactive (list (read-directory-name "Project directory: ")))
  (slime-start :program "qlot"
               :program-args '("exec" "ros" "-S" "." "-L" "sbcl-bin" "-Q" "dynamic-space-size=1024" "-l" "~/.sbclrc" "run")
               :directory directory
               :name 'qlot
               :env (list (concat "PATH="
                                  (mapconcat 'identity exec-path ":")))))
```
のようなコマンドを設定ファイル内などで定義し、`M-x slime-qlot-exec`をからSLIMEを起動することで同じことができる。

`program-args`の部分にqlotコマンドの引数を指定しており、`ros run`でSBCLをヒープ領域指定オプション(`dynamic-space-size`)などを付けて起動していることが分かる。

# DBの準備

cl-dbiではSQLite3, PostgreSQL, MySQLに接続できる。ここでは実務で使っているPostgreSQLで話を進めることにする。

まず何らかの方法でPostgreSQLをインストールする。

```
$ sudo apt install postgresql
```

次にblogという名前のデータベースを作る。さらにデータベースと同名のユーザを作り、パスワードを設定する。

```
$ createdb blog
$ createuser -d blog
$ psql postgres

ALTER USER blog WITH PASSWORD 'blog';
```

psqlでユーザblog、パスワードblogで、blogデータベースに接続できることを確認する。
この段階ではまだテーブルは無い。

```
psql -h localhost -U blog blog
Password for user blog: blog
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

blog=> \d
Did not find any relations.
```

## テーブル定義

DBにテーブルを追加したり変更を加えるときには、まずmitoのテーブルクラスを定義/編集し、続いて`utopian generate migration`コマンドでマイグレーションファイルを生成する。
このコマンドは`models/`以下のテーブルクラス定義の変更を検出し、対応するマイグレーションSQLをファイル`db/migrations/`以下に生成する。

例えば`user`というテーブルクラスを新規に定義する場合、`models/user.lisp`というファイルを新規に作り、以下のような内容にする。

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

なお Utopian は package-inferred-system の使用を前提としており、ファイル名やパスとパッケージ名が一致している必要があることに注意。

### マイグレーションファイルの生成

まず `config/environments/local.lisp` にDBへの接続情報を記載しておく。

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

次にモデル層(`models/`)の変更差分からマイグレーションファイルを生成する。

```
$ .qlot/bin/utopian generate migration

Loading model files...Done    
CREATE TABLE "user" (
    "id" BIGSERIAL NOT NULL PRIMARY KEY,
    "name" VARCHAR(256) NOT NULL,
    "created_at" TIMESTAMPTZ,
    "updated_at" TIMESTAMPTZ
);
Successfully generated: db/migrations/20211121074550.up.sql
```

`db/migrations/20211121074550.up.sql` というファイルが新規に生成され、中身にはテーブル定義SQLが入っていることが分かる。

この時点ではマイグレーションファイルができたのみでまだDBには変更が適用されていない。

マイグレーションファイルを適用するには`utopian db migrate`コマンドを使う。

```
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

Successfully updated to the version "20211121074550".
```


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
