(defpackage #:blog/models/user
  (:use #:cl
        #:mito)
  (:export #:user
           #:user-name))
(in-package #:blog/models/user)

(deftable user ()
  ((name :col-type (:varchar 256)
         :initform "")))
