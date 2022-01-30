(defpackage #:blog/tests/utils
  (:use #:cl)
  (:import-from #:alexandria
                #:with-gensyms
                #:once-only
                #:remove-from-plist)
  (:import-from #:clack)
  (:import-from #:lack.test)
  (:import-from #:lack.response)
  (:import-from #:assoc-utils)
  (:import-from #:jonathan
                #:to-json)
  (:export #:testing-api
           #:successp
           #:json-response-p
           #:response-body
           #:response-headers
           #:alist-match))
(in-package #:blog/tests/utils)

(defmacro testing-api ((method uri &rest args &key headers content &allow-other-keys)
                       (response)
                       &body body)
  (with-gensyms (response-body status response-headers)
    (once-only (headers uri content)
      `(let ((,headers (if (assoc "content-type" ,headers :test #'equal)
                           ,headers
                           (acons "content-type" "application/json" ,headers))))
         (when (equal (assoc-utils:aget ,headers "content-type") "application/json")
           (setf ,content (etypecase ,content
                            (string ,content)
                            (assoc-utils:alist (to-json ,content :from :alist)))))
         (lack.test:testing-app (clack:eval-file (asdf:system-relative-pathname :blog #P"app.lisp"))
           (multiple-value-bind (,response-body ,status ,response-headers)
               (lack.test:request ,uri :method ,method :headers ,headers :content ,content
                                  ,@(remove-from-plist args :headers :content))
             (let ((,response (lack.response:make-response ,status ,response-headers ,response-body)))
               ,@body)))))))

(defun successp (response)
  (<= 200 (lack.response:response-status response) 299))

(defun json-response-p (response)
  (equal (gethash "content-type" (lack.response:response-headers response)) "application/json"))

(defun response-body (response)
  (cond
    ((json-response-p response)
     (let ((jojo:*null-value* :null))
       (jojo:parse (lack.response:response-body response) :as :alist)))
    (t
     (lack.response:response-body response))))

(defun response-headers (response)
  (assoc-utils:hash-alist (lack.response:response-headers response)))

(defun alist-match (rules alist &key (verbose nil))
  (and (every (lambda (key-pred)
                (destructuring-bind (key . pred) key-pred
                  (let* ((pair (assoc key alist :test #'equal))
                         (result (and pair
                                      (typecase pred
                                        (function
                                         (funcall pred (cdr pair)))
                                        (cons
                                         (if (eq (first pred) 'cl:function)
                                             (funcall (second pred) (cdr pair))
                                             (equal pred (cdr pair))))
                                        (otherwise
                                         (equal pred (cdr pair)))))))
                    (when verbose
                      (format t "key: ~A, result: ~A pair: ~S~%" key result pair))
                    result)))
              rules)
       (equalp (sort (mapcar #'car alist) #'string<=)
               (sort (mapcar #'car rules) #'string<=))))
