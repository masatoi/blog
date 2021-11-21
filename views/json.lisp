(defpackage #:blog/views/json
  (:use #:cl
        #:utopian
        #:utopian/views)
  (:import-from #:mito)
  (:import-from #:blog/utils/models
                #:as-alist)
  (:export #:json-view
           #:json-view-class
           #:render-json))
(in-package #:blog/views/json)

(defclass json-view-class (utopian-view-class)
  ()
  (:default-initargs
   :content-type "application/json"))

(defview json-view ()
  ((object :initarg :object))
  (:metaclass json-view-class)
  (:render (jojo:to-json
            (if (typep object 'mito.dao.mixin:dao-class)
                (as-alist object)
                object)
            :from :alist)))

(defun render-json (object)
  (render 'json-view :object object))
