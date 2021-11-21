(defpackage #:blog/controllers/users
  (:use #:cl
        #:mito
        #:utopian)
  (:import-from #:blog/models/user
                #:user)
  (:import-from #:blog/views/json
                #:render-json)
  (:export #:listing
           #:show
           #:create
           #:update))
(in-package #:blog/controllers/users)

(defun listing (params)
  (declare (ignore params))
  (render-json (find-dao 'user)))

(defun show (params)
  (declare (ignore params))
  (render-json (find-dao 'user)))

(defun show (params)
  (declare (ignore params))
  (render-json (find-dao 'user)))

(defun show (params)
  (declare (ignore params))
  (render-json (find-dao 'user)))
