(defpackage #:blog/tests/functional/users/listing
  (:use #:cl
        #:rove
        #:blog/tests/utils
        #:blog/repositories/user)
  (:import-from #:blog/models/mixin/uuid-pk
                #:object-uuid)
  (:import-from #:assoc-utils
                #:aget))
(in-package #:blog/tests/functional/users/listing)

(defun user-rows-p (rows)
  (every (lambda (row)
           (alist-match '(("name" . #'stringp)
                          ("id" . #'stringp)
                          ("created_at" . #'local-time:parse-timestring)
                          ("updated_at" . #'local-time:parse-timestring))
                        row))
         rows))

(deftest listing-tests
  (let ((users (loop repeat 10 collect (create-user :name (random-string)))))
    (testing "Can get users"
      (testing-api (:GET "/users")
          (response)
        (ok (successp response))
        (ok (alist-match '(("rows" . #'user-rows-p))
                         (response-body response)))
        (ok (equal (mapcar (lambda (row)
                             (aget row "id"))
                           (aget (response-body response) "rows"))
                   (reverse (mapcar #'object-uuid users))))))
    (testing "Can get users with per_page"
      (testing-api (:GET "/users?per_page=5")
          (response)
        (ok (successp response))
        (ok (alist-match '(("rows" . #'user-rows-p))
                         (response-body response)))
        (ok (equal (mapcar (lambda (row)
                             (aget row "id"))
                           (aget (response-body response) "rows"))
                   (subseq (reverse (mapcar #'object-uuid users)) 0 5)))))
    (testing "Can get users with per_page"
      (testing-api (:GET "/users?per_page=-5")
          (response)
        (ng (successp response))
        (ok (alist-match '(("type" . "invalid_parameters")
                           ("errors" ("invalid" "per_page")))
                         (response-body response)))))))
