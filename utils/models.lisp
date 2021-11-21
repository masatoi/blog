(defpackage #:blog/utils/models
  (:use #:cl)
  (:import-from #:mito)
  (:import-from #:utopian)
  (:import-from #:closer-mop)
  (:import-from #:jonathan)
  (:export #:as-alist))
(in-package #:blog/utils/models)

(defgeneric as-alist (object &key includes excludes)
  (:method ((object mito:dao-class) &key includes excludes)
    (loop for slot in (mito.class:table-column-slots (class-of object))
          for slot-name = (c2mop:slot-definition-name slot)
          when (or (find slot-name includes :test #'string=)
                   (and (not (find slot-name excludes :test #'string=))
                        (cond
                          ((mito.class.column:ghost-slot-p slot)
                           nil)
                          ((mito.class.column:table-column-references slot)
                           nil)
                          (t))
                        (slot-boundp object slot-name)))
            collect
            (let ((value (slot-value object slot-name)))
              (cons (mito.class:table-column-name slot)
                    (cond
                      ((eq (mito.class:table-column-type slot) :boolean)
                       (if value t :false))
                      (t
                       (typecase value
                         (mito:dao-class (as-alist value))
                         (null jojo:*null-value*)
                         (otherwise value)))))))))
