(defpackage #:blog/controllers/root
  (:use #:cl
        #:utopian
        #:blog/views/root)
  (:export #:index))
(in-package #:blog/controllers/root)

(defun index (params)
  (declare (ignore params))
  (render 'index-page))
