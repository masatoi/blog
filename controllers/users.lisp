(defpackage #:blog/controllers/users
  (:use #:cl
        #:mito
        #:utopian)
  (:import-from #:blog/models/user
                #:user)
  (:import-from #:blog/views/user
                #:user-view)
  (:export #:listing))
(in-package #:blog/controllers/users)

(defun listing (params)
  (declare (ignore params))
  (print "in listing")
  ;; (find-dao 'user)
  ;; (render 'user-view)
  )

;; '(("message" . "hello")) :as :json
