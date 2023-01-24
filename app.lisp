(defpackage #:blog/app
  (:use #:cl
        #:blog/config/routes
        #:blog/config/application)
  (:import-from #:lack.component
                #:to-app)
  (:import-from #:utopian/config
                #:getenv))
(in-package #:blog/app)

(let ((app (make-instance 'blog-app
                          :routes *routes*
                          :models #P"models/")))
  (if (getenv "WITHOUT_MIDDLEWARE")
      app
      (to-app app)))
