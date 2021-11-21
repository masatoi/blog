(defpackage #:blog/repositories/user
  (:use #:cl
        #:mito
        #:sxql)
  (:import-from #:blog/models/user
                #:user
                #:user-name)
  (:export #:find-user
           #:select-users
           #:create-user
           #:update-user))
(in-package #:blog/repositories/user)

(defun select-users ()
  (mito:select-dao 'user))

(defun find-user (&key id)
  (apply #'mito:find-dao 'user
         `(,@(and id `(:uuid ,id)))))

(defun create-user (&key (name ""))
  (mito:create-dao 'user :name name))

(defun update-user (user &key name)
  (when name
    (setf (user-name user) name))
  (save-dao user)
  user)
