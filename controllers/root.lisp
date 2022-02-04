(defpackage #:blog/controllers/root
  (:use #:cl
        #:utopian
        #:blog/views/root)
  (:import-from #:blog/views/json
                #:render-json)
  (:export #:index
           #:ping))
(in-package #:blog/controllers/root)

(defun index (params)
  (declare (ignore params))
  (render 'index-page))

(defun ping (params)
  (declare (ignore params))
  (render-json `(("pong" . "ok"))))
