(defpackage #:blog/errors/base
  (:use #:cl)
  (:import-from #:utopian)
  (:import-from #:jonathan)
  (:export #:get-error-message
           #:http-error
           #:http-error-type
           #:http-error-message
           #:http-error-object
           #:http-error-resolve-url
           #:bad-request
           #:unauthorized
           #:forbidden
           #:not-found
           #:entity-conflict
           #:entity-gone
           #:unprocessable-request
           #:temporarily-unavailable
           #:invalid-parameters))
(in-package #:blog/errors/base)

(defgeneric get-error-message (error)
  (:method (error)
    nil))

(define-condition http-error (utopian:http-exception)
  ((type :initarg :type
         :accessor http-error-type)
   (message :initarg :message
            :accessor http-error-message)
   (error :initarg :error
          :initform nil
          :accessor http-error-object)
   (resolve-url :initarg :resolve-url
                :initform nil
                :accessor http-error-resolve-url)))

(defmethod http-error-message :before ((error http-error))
  (unless (slot-boundp error 'message)
    (setf (slot-value error 'message)
          (get-error-message error))))

(defmethod jojo:%to-json ((error http-error))
  (let ((type (http-error-type error))
        (message (http-error-message error))
        (resolve-url (http-error-resolve-url error))
        (object (http-error-object error)))
    (jojo:with-object
      (jojo:write-key-value "type" type)
      (when message
        (jojo:write-key-value "message" message))
      (when resolve-url
        (jojo:write-key-value "resolve"
                              (jojo:with-object
                                (jojo:write-key-value "url" resolve-url))))
      (when object
        (jojo:write-key-value "object"
                              object)))))

(define-condition bad-request (http-error)
  ()
  (:default-initargs :code 400))

(define-condition unauthorized (http-error)
  ()
  (:default-initargs :code 401))

(define-condition forbidden (http-error)
  ()
  (:default-initargs
   :code 403
   :type "forbidden"))

(define-condition not-found (http-error)
  ()
  (:default-initargs
   :code 404
   :type "notfound"))

(define-condition entity-conflict (http-error)
  ()
  (:default-initargs :code 409))

(define-condition entity-gone (http-error)
  ()
  (:default-initargs :code 410))

(define-condition unprocessable-request (http-error)
  ()
  (:default-initargs
   :code 422
   :type "unprocessable"))

(define-condition temporarily-unavailable (http-error)
  ()
  (:default-initargs
   :code 503
   :type "temporarily_unavailable"))

(define-condition invalid-parameters (bad-request)
  ((missing :initarg :missing
            :initform '()
            :reader invalid-parameters-missing)
   (invalid :initarg :invalid
            :initform '()
            :reader invalid-parameters-invalid)
   (unpermitted :initarg :unpermitted
                :initform '()
                :reader invalid-parameters-unpermitted))
  (:default-initargs
   :type "invalid_parameters"))

(defmethod jojo:%to-json ((error invalid-parameters))
  (let ((type (http-error-type error))
        (message (http-error-message error))
        (missing (invalid-parameters-missing error))
        (invalid (invalid-parameters-invalid error))
        (unpermitted (invalid-parameters-unpermitted error)))
    (jojo:with-object
      (jojo:write-key-value "type" type)
      (when message
        (jojo:write-key-value "message" message))
      (when (or missing invalid unpermitted)
        (jojo:write-key-value "errors"
                              (jojo:with-object
                                (when missing
                                  (jojo:write-key-value "missing"
                                                        (let ((*print-case* :downcase))
                                                          (mapcar #'princ-to-string missing))))
                                (when invalid
                                  (jojo:write-key-value "invalid"
                                                        (let ((*print-case* :downcase))
                                                          (mapcar #'princ-to-string invalid))))
                                (when unpermitted
                                  (jojo:write-key-value "unpermitted"
                                                        (let ((*print-case* :downcase))
                                                          (mapcar #'princ-to-string unpermitted))))))))))
