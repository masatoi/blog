(defpackage #:blog/utils/validation
  (:use #:cl)
  (:import-from #:mito)
  (:import-from #:utopian)
  (:import-from #:closer-mop)
  (:import-from #:jonathan)
  (:export #:as-alist))
(in-package #:blog/utils/validation)

(eval-when-always
 (defun lisp-variable-to-request-parameter-name (name)
   (format nil "~{~(~A~)~^_~}" (uiop:split-string (string name) :separator "-"))))

(defmacro with-request-parameters (bindings params &body body)
  (alexandria:once-only (params)
    `(let ,(mapcar (lambda (b)
                     (destructuring-bind
                         (var &key (key
                                    (lisp-variable-to-request-parameter-name var))
                                   default)
                         (alexandria:ensure-list b)
                       `(,var (aget ,params ,key ,default))))
            bindings)
       ,@body)))
