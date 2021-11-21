(defpackage #:blog/config/routes
  (:use #:cl
        #:utopian)
  (:export #:*routes*))
(in-package #:blog/config/routes)

(defroutes *routes* ()
  (:controllers #P"../controllers/"))

(route :GET "/" "root:index")
