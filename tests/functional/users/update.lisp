(defpackage #:blog/tests/functional/users/update
  (:use #:cl
        #:rove
        #:blog/tests/utils
        #:blog/repositories/user)
  (:import-from #:blog/models/mixin/uuid-pk
                #:object-uuid))
(in-package #:blog/tests/functional/users/update)

(deftest update-tests
  (let* ((name (random-string))
         (user (create-user :name name)))
    (testing "Can update a user infomations"
      (testing-api (:PATCH (format nil "/users/~A" (object-uuid user))
                           :content '(("name" . "new name")))
          (response)
        (ok (successp response))
        (ok (alist-match `(("name" . "new name")
                           ("id" . ,(object-uuid user))
                           ("created_at" . #'local-time:parse-timestring)
                           ("updated_at" . #'local-time:parse-timestring))
                         (response-body response)))))
    (testing "Invalid name"
      (flet ((invalid-name-test (name)
               (testing-api (:PATCH (format nil "/users/~A" (object-uuid user))
                             :content `(("name" . ,name)))
                   (response)
                 (ng (successp response))
                 (ok (= (response-status response) 400))
                 (ok (alist-match '(("type" . "invalid_parameters")
                                    ("errors" . (("invalid" "name"))))
                                  (response-body response))))))
        (invalid-name-test 10)
        (invalid-name-test (random-string 400))))
    (testing "If a string that is not a uuid is specified, an invalid_parameters error will occur."
      (testing-api (:PATCH (format nil "/users/~A" (random-string)))
          (response)
        (ng (successp response))
        (ok (= (response-status response) 400))
        (ok (alist-match '(("type" . "invalid_parameters")
                           ("errors" . (("invalid" "user_id"))))
                         (response-body response)))))
    (testing "User not found"
      (testing-api (:PATCH (format nil "/users/~A" (generate-uuid)))
          (response)
        (ng (successp response))
        (ok (= (response-status response) 404))
        (ok (alist-match '(("type" . "notfound"))
                         (response-body response)))))))
