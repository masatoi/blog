(defpackage #:blog/views/json
  (:use #:cl
        #:utopian/views)
  (:export #:json-view
           #:json-view-class))
(in-package #:blog/views/json)

(defclass json-view (utopian-view) ())
(defclass json-view-class (utopian-view-class)
  ()
  (:default-initargs
   :content-type "application/json"))
