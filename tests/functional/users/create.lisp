(defpackage #:blog/tests/functional/users/create
  (:use #:cl
        #:rove
        #:blog/tests/utils
        #:blog/repositories/user))
(in-package #:blog/tests/functional/users/create)

(deftest create-tests
  (let ((name (random-string)))
    (testing "Can create a user"
      (testing-api (:POST "/users" :content `(("name" . ,name)))
          (response)
        (ok (successp response))
        (ok (alist-match `(("name" . ,name)
                           ("id" . #'stringp)
                           ("created_at" . #'local-time:parse-timestring)
                           ("updated_at" . #'local-time:parse-timestring))
                         (response-body response)))))

    (testing "Invalid name"
      (flet ((invalid-name-test (name)
               (testing-api (:POST "/users" :content `(("name" . ,name)))
                   (response)
                 (ng (successp response))
                 (ok (= (response-status response) 400))
                 (ok (alist-match '(("type" . "invalid_parameters")
                                    ("errors" . (("invalid" "name"))))
                                  (response-body response))))))
        (invalid-name-test 10)
        (invalid-name-test (random-string 400))))))
