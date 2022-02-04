(defpackage #:blog/controllers/users
  (:use #:cl
        #:mito
        #:utopian
        #:blog/errors/base)
  (:import-from #:blog/repositories/user
                #:select-users
                #:find-user
                #:create-user
                #:update-user)
  (:import-from #:blog/views/json
                #:render-json)
  (:import-from #:blog/utils/models
                #:as-alist)
  (:import-from #:blog/utils/validation
                #:with-request-parameters)
  (:export #:listing
           #:show
           #:create
           #:update))
(in-package #:blog/controllers/users)

(defun listing (params)
  (with-request-parameters ((per-page :default 10))
      params
    (let ((users (select-users :per-page per-page)))
      (render-json `(("rows" . ,(mapcar #'as-alist users)))))))

(defun show (params)
  (with-request-parameters ((uuid :key :uuid))
      params
    (let ((user (or (find-user :id uuid)
                    (error 'not-found))))
      (render-json user))))

(defun create (params)
  (with-request-parameters ((name :default ""))
      params
    (render-json (create-user :name name))))

(defun update (params)
  (with-request-parameters ((uuid :key :uuid)
                            name)
      params
    (let ((user (or (find-user :id uuid)
                    (error 'not-found))))
      (render-json
       (update-user user :name name)))))
