(defpackage #:blog/models/mixin/uuid-pk
  (:use #:cl
        #:mito)
  (:import-from #:uuid
                #:make-v4-uuid)
  (:export #:uuid-pk-mixin
           #:object-uuid
           #:generate-uuid))
(in-package #:blog/models/mixin/uuid-pk)

(defun generate-uuid ()
  (format nil "~(~A~)" (make-v4-uuid)))

(defclass uuid-pk-mixin ()
  ((uuid :col-type (:varchar 36)
         :initform (generate-uuid)
         :accessor object-uuid
         :primary-key t))
  (:metaclass dao-table-mixin))

(defmethod mito:object= ((object1 uuid-pk-mixin) (object2 uuid-pk-mixin))
  (equal (object-uuid object1)
         (object-uuid object2)))

(defmethod mito:object-id ((object uuid-pk-mixin))
  (object-uuid object))

(defmethod print-object ((object uuid-pk-mixin) stream)
  (print-unreadable-object (object stream :type t :identity t)
    (format stream ":ID ~A"
            (subseq (object-uuid object) 0 8))))
