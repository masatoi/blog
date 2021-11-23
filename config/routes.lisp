(defpackage #:blog/config/routes
  (:use #:cl
        #:utopian)
  (:export #:*routes*))
(in-package #:blog/config/routes)

(defroutes *routes* ()
  (:controllers #P"../controllers/"))

(route :GET "/" "root:index")
(route :GET "/users" "users:listing")
(route :GET "/users/:uuid" "users:show")
(route :POST "/users" "users:create")
(route :PATCH "/users" "users:update")
