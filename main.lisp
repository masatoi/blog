(defpackage #:blog
  (:nicknames #:blog/main)
  (:use #:cl)
  (:import-from #:repl-utilities
                #:*dev-hooks*)
  (:import-from #:cl-debug-print)
  (:import-from #:cl-interpol)
  (:import-from #:blog/config/application)
  (:import-from #:blog/config/routes)
  (:import-from #:blog/views)
  (:import-from #:clack)
  (:import-from #:utopian
                #:config)
  (:import-from #:mito)
  (:export #:start-blog
           #:stop-blog
           #:connect-db
           #:toggle-sql-logger))
(in-package #:blog)

(defvar *blog-app*)

(setf utopian:*config-dir*
      (merge-pathnames #P"config/environments/" (asdf:system-source-directory :blog)))

(defun start-blog (&rest args &key (server :hunchentoot)
                                   (port 5000)
                                   (debug t)
                   &allow-other-keys)
  (declare (ignorable args))
  (setf *blog-app*
        (clack:clackup (merge-pathnames #P"app.lisp" (asdf:system-source-directory :blog))
                       :server server
                       :port port
                       :debug debug))
  *blog-app*)

(defun stop-blog ()
  (clack:stop *blog-app*))

(defun connect-db (&optional (db :maindb))
  (apply #'mito:connect-toplevel (utopian:db-settings db)))

(defvar *use-sql-logger* nil)
(defun toggle-sql-logger ()
  (setf mito:*mito-logger-stream*
        (and (setf *use-sql-logger*
                   (not *use-sql-logger*))
             *standard-output*)))

(defun enable-read-macros ()
  (cl-interpol:enable-interpol-syntax)
  (cl-debug-print:use-debug-print))

(pushnew 'enable-read-macros *dev-hooks*)
