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

(defmethod jojo:%to-json ((time local-time:timestamp))
  (jojo:%to-json (local-time:format-timestring nil time :timezone local-time:+utc-zone+)))

(defmethod jojo:%to-json ((object standard-object))
  (let ((jojo:*from* :alist)
        (jojo:*null-value* :null))
    (jojo:%to-json (as-alist object))))

(defun render-json (object)
  (render 'json-view :object object))
