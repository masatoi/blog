(defpackage #:blog/config/application
  (:use #:cl
        #:utopian
        #:blog/views/json
        #:blog/errors/base)
  (:import-from #:lack.component
                #:to-app
                #:call)
  (:import-from #:lack
                #:builder)
  (:import-from #:apispec)
  (:import-from #:cl-ppcre)
  (:import-from #:alexandria
                #:when-let)
  (:import-from #:sanitized-params
                #:validation-error
                #:missing-keys
                #:invalid-keys
                #:unpermitted-keys)
  (:export #:blog-app))
(in-package #:blog/config/application)

(defparameter *spec*
  (apispec:load-from-file (asdf:system-relative-pathname :blog "docs/api/blog.yaml")))

(defun validate-request-if-defined-in-openapi (env)
  (let ((request-method (getf env :request-method))
        (path-info (getf env :path-info)))
    (multiple-value-bind (operation path-parameters)
        (apispec:find-route (apispec:spec-router *spec*)
                            request-method
                            path-info)
      (when operation
        (apispec:validate-request operation
                                  env
                                  :path-parameters path-parameters)))))

(defapp blog-app ()
  ()
  (:config #P"environments/")
  (:content-type "text/html; charset=utf-8"))

(defmethod call ((app blog-app) env)
  (let ((apispec/classes/schema:*coerce-string-to-boolean* t))
    (handler-case
        (handler-bind ((error
                         (lambda (e)
                           (unless (or (typep e 'sanitized-params:validation-error)
                                       (typep e 'apispec:schema-object-error)
                                       (typep e 'apispec:parameter-validation-failed))
                             ;; TODO: call logger
                             (format t "internal error: ~A~%" e)))))
          (when-let (request (validate-request-if-defined-in-openapi env))
            (setf *request* request))
          (call-next-method))
      (sanitized-params:validation-error (e)
        (setf (response-status *response*) 400)
        (on-exception app
                      (make-condition
                       'invalid-parameters
                       :error e
                       :missing (missing-keys e)
                       :invalid (invalid-keys e)
                       :unpermitted (unpermitted-keys e))))
      (apispec:parameter-validation-failed (e)
        (setf (response-status *response*) 400)
        (on-exception app
                      (make-condition
                       'invalid-parameters
                       :error e
                       :missing (apispec:missing-parameters e)
                       :invalid (mapcar #'car (apispec:invalid-parameters e))
                       :unpermitted (apispec:unpermitted-parameters e))))
      (apispec:schema-object-error (e)
        (setf (response-status *response*) 400)
        (on-exception app
                      (make-condition
                       'invalid-parameters
                       :error e
                       :missing (apispec:schema-object-error-missing-keys e)
                       :invalid (apispec:schema-object-error-invalid-keys e)
                       :unpermitted (apispec:schema-object-error-unpermitted-keys e)))))))

(defmethod to-app ((app blog-app))
  (builder
   (:static
    :path (lambda (path)
            (if (ppcre:scan "^(?:/assets/|/robot\\.txt$|/favicon\\.ico$)" path)
                path
                nil))
    :root (asdf:system-relative-pathname :blog #P"public/"))
   :accesslog
   (:mito (db-settings :maindb))
   :session
   (call-next-method)))

(defmethod on-exception ((app blog-app) (c http-error))
  `(400
    (:content-type "application/json")
    (,(render-json c))))
