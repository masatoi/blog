#.`(uiop:define-package #:blog/models
       (:use #:cl)
     (:use-reexport ,@(labels ((directory-models (dir)
                                 (append
                                  (uiop:directory-files dir "*.lisp")
                                  (mapcan #'directory-models (uiop:subdirectories dir)))))
                        (mapcar (lambda (file)
                                  (second
                                   (asdf/package-inferred-system::file-defpackage-form file)))
                                (directory-models (asdf:system-relative-pathname '#:blog #P"models/"))))))
(in-package #:blog/models)
