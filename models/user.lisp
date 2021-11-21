(defpackage #:blog/models/user
  (:use #:cl
        #:mito)
  (:import-from #:blog/models/mixin/uuid-pk
                #:uuid-pk-mixin)
  (:export #:user
           #:user-name))
(in-package #:blog/models/user)

(deftable user (uuid-pk-mixin)
  ((name :col-type (:varchar 256)
         :initform "")))
