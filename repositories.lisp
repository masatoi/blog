#.`(uiop:define-package #:blog/repositories
       (:use #:cl)
     (:nicknames :repos)
     (:use-reexport ,@(labels ((directory-repositories (dir)
                                 (append
                                  (uiop:directory-files dir "*.lisp")
                                  (mapcan #'directory-repositories (uiop:subdirectories dir)))))
                        (mapcar (lambda (file)
                                  (second
                                   (asdf/package-inferred-system::file-defpackage-form file)))
                                (directory-repositories (asdf:system-relative-pathname '#:blog #P"repositories/"))))))
(in-package #:blog/repositories)
