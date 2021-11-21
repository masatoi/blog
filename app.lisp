(defpackage #:blog/app
  (:use #:cl
        #:blog/config/routes
        #:blog/config/application))
(in-package #:blog/app)

(make-instance 'blog-app
               :routes *routes*
               :models #P"models/")
