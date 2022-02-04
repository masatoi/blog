(defpackage #:blog/app
  (:use #:cl
        #:blog/config/routes
        #:blog/config/application)
  (:import-from #:lack.component
                #:to-app))
(in-package #:blog/app)

(to-app
 (make-instance 'blog-app
                :routes *routes*
                :models #P"models/"))
