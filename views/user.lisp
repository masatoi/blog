(defpackage #:blog/views/user
  (:use #:cl
        #:utopian)
  (:import-from #:blog/models/user
                #:user
                #:user-name)
  (:import-from #:blog/models/mixin/uuid-pk
                #:object-uuid)
  (:import-from #:blog/utils/models
                #:as-alist))
(in-package #:blog/views/user)

(defmethod as-alist ((user user) &key includes excludes)
  (declare (ignore includes excludes))
  `(("id" . ,(object-uuid user))
    ("name" . ,(user-name user))
    ("created_at" . ,(mito:object-created-at user))
    ("updated_at" . ,(mito:object-updated-at user))))
