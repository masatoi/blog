(defpackage #:blog/views/user
  (:use #:cl
        #:utopian)
  (:import-from #:blog/models/user
                #:user
                #:user-name)
  (:import-from #:blog/utils/models
                #:as-alist))
(in-package #:blog/views/user)

(defmethod as-alist ((user user) &key includes excludes)
  (declare (ignore includes excludes))
  `(("name" . ,(user-name user))))
