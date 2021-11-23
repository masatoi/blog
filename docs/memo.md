$ ros install fukamachi/qlot
$ ros install fukamachi/utopian

$ utopian new blog

Description: sample web app
Author: Satoshi Imai
Database [sqlite3]: postgres
License: MIT

New project is created at '/home/wiz/blog/'.

$ qlot install

Installing Quicklisp to /home/wiz/blog/.qlot/ ...
; Fetching #<URL "http://beta.quicklisp.org/quicklisp.lisp">
; 55.80KB
==================================================
57,144 bytes in 0.00 seconds (0.00KB/sec)
Reading '/home/wiz/blog/qlfile'...
Installing dist "quicklisp" version "2021-10-21".
Downloading http://beta.quicklisp.org/dist/quicklisp/2021-10-21/releases.txt
##########################################################################
Downloading http://beta.quicklisp.org/dist/quicklisp/2021-10-21/systems.txt
##########################################################################
Installing dist "utopian" version "git-c6ad73d5a9bba245ad7b747e7764c94e3ea0ba23".
Installing dist "clack" version "ql-2021-10-21".
Downloading http://beta.quicklisp.org/archive/clack/2021-08-07/clack-20210807-git.tgz
##########################################################################
Loading '/home/wiz/blog/blog.asd'...
Ensuring 12 dependencies installed.
Downloading http://beta.quicklisp.org/archive/lack/2021-10-20/lack-20211020-git.tgz
##########################################################################
Downloading http://beta.quicklisp.org/archive/uiop/2021-08-07/uiop-3.3.5.tgz
##########################################################################
Downloading http://beta.quicklisp.org/archive/ironclad/2021-10-20/ironclad-v0.56.tgz
##########################################################################
Downloading http://beta.quicklisp.org/archive/bordeaux-threads/2020-06-10/bordeaux-threads-v0.8.8.tgz
##########################################################################
Downloading http://beta.quicklisp.org/archive/alexandria/2021-08-07/alexandria-20210807-git.tgz
##########################################################################
Downloading http://beta.quicklisp.org/archive/cl-ppcre/2019-05-21/cl-ppcre-20190521-git.tgz
##########################################################################
Downloading http://beta.quicklisp.org/archive/lsx/2021-10-20/lsx-20211020-git.tgz
##########################################################################
Downloading http://beta.quicklisp.org/archive/closer-mop/2021-10-20/closer-mop-20211020-git.tgz
##########################################################################
Downloading http://beta.quicklisp.org/archive/named-readtables/2021-05-31/named-readtables-20210531-git.tgz
##########################################################################
Successfully installed.

# qlfileを編集

git utopian https://github.com/fukamachi/utopian
ql clack :latest
git apispec https://github.com/cxxxr/apispec :branch develop

# qlot exec でREPLを起動(M-x slime-qlot-exec)

# DBを作成

$ createuser -d blog
$ createdb blog

$ psql postgres

ALTER USER blog WITH PASSWORD 'blog';

psql -h localhost -U blog blog

# テーブル定義

#+begin_src lisp
(defpackage #:blog/models/user
  (:use #:cl
        #:mito)
  (:export #:user
           #:user-name))
(in-package #:blog/models/user)

(deftable user ()
  ((name :col-type (:varchar 256)
         :initform "")))
#+end_src

# DBマイグレーション

blog/config/environments/local でパスワードを設定しておく

#+begin_src lisp
(defpackage #:blog/config/environments/local
  (:use #:cl))
(in-package #:blog/config/environments/local)

`(:databases
  ((:maindb . (:postgres
               :database-name "blog"
               :username "blog"
               :password "blog"))))
#+end_src

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
