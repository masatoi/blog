(defpackage #:blog/views/user
  (:use #:cl
        #:utopian)
  (:import-from #:blog/views/json
                #:json-view-class)
  (:import-from #:blog/models/user
                #:user
                #:user-name)
  (:export #:user-view))
(in-package #:blog/views/user)

(defview user-view ()
  ((user :initarg :user
         :type 'user
         :initform nil))
  (:metaclass json-view-class)
  (:render
   (jojo:to-json `(("name" . ,(user-name user)))
                 :from :alist)))
