(defpackage #:blog/config/environments/local
  (:use #:cl))
(in-package #:blog/config/environments/local)

`(:databases
  ((:maindb . (:postgres
               :database-name "blog"
               :username "blog"
               :password "blog"))))
