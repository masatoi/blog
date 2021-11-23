(defpackage #:blog/controllers/users
  (:use #:cl
        #:mito
        #:utopian)
  (:import-from #:blog/repositories/user
                #:select-users
                #:find-user
                #:create-user
                #:update-user)
  (:import-from #:blog/views/json
                #:render-json)
  (:import-from #:blog/utils/models
                #:as-alist)
  (:export #:listing
           #:show
           #:create
           #:update))
(in-package #:blog/controllers/users)

(defun listing (params)
  (declare (ignore params))
  (let ((users (select-users)))
    (render-json `(("rows" . ,(mapcar #'as-alist users))))))

(defun show (params)
  ;;(declare (ignore params))
  #>params
  (let ((id (cdr (assoc :uuid params))))
    (render-json (or (find-user :id id) :null))))

(defun create (params)
  (declare (ignore params))
  (render-json (find-dao 'user)))

(defun update (params)
  (declare (ignore params))
  (render-json (find-dao 'user)))
