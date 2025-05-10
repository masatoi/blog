(defpackage #:blog/utils/prng
  (:nicknames #:lack.middleware.prng)
  (:use #:cl)
  (:import-from #:bordeaux-threads
                #:current-thread
                #:with-lock-held)
  (:import-from #:ironclad
                #:make-prng
                #:*prng*
                #:*os-prng-stream*
                #:*os-prng-stream-lock*)
  (:export #:*lack-middleware-prng*
           #:refresh-prng
           #:with-prng))
(in-package #:blog/utils/prng)

(defparameter *prng-cache*
  (make-hash-table :test 'eq))

(defvar *prng-initargs*)

(defvar *refresh-prng-lock*
  (bt:make-lock "REFRESH-PRNG-LOCK"))

(defun refresh-prng ()
  (when *os-prng-stream*
    (bt:with-lock-held (*os-prng-stream-lock*)
      (setf *os-prng-stream* nil)))
  (bt:with-lock-held (*refresh-prng-lock*)
    (setf (gethash (bt:current-thread) *prng-cache*)
          (apply #'ironclad:make-prng *prng-initargs*))))

(defun call-with-prng (name args main)
  (let* ((*prng-initargs* (cons name args))
         (ironclad:*prng* (or (gethash (bt:current-thread) *prng-cache*)
                              (refresh-prng))))
    (funcall main)))

(defmacro with-prng ((name args) &body body)
  `(call-with-prng ,name ,args (lambda () ,@body)))

(defparameter *lack-middleware-prng*
  (lambda (app name &rest args &key seed cipher)
    (declare (ignore seed cipher))
    (lambda (env)
      (with-prng (name args)
        (funcall app env)))))
