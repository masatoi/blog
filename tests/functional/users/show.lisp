(defpackage #:blog/tests/functional/users/show
  (:use #:cl
        #:rove
        #:blog/tests/utils
        #:blog/repositories/user)
  (:import-from #:blog/models/mixin/uuid-pk
                #:object-uuid
                #:generate-uuid))
(in-package #:blog/tests/functional/users/show)

(deftest show-tests
  (let* ((name (random-string))
         (user (create-user :name name)))
    (testing "Can show a user infomations"
      (testing-api (:GET (format nil "/users/~A" (object-uuid user)))
          (response)
        (ok (successp response))
        (ok (alist-match `(("name" . ,name)
                           ("uuid" . ,(object-uuid user))
                           ("created_at" . #'local-time:parse-timestring)
                           ("updated_at" . #'local-time:parse-timestring))
                         (response-body response)))))
    (testing "If a string that is not a uuid is specified, an invalid_parameters error will occur."
      (testing-api (:GET (format nil "/users/~A" (random-string)))
          (response)
        (ng (successp response))
        (ok (= (response-status response) 400))
        (ok (alist-match '(("type" . "invalid_parameters")
                           ("errors" . (("invalid" "user_id"))))
                         (response-body response)))))
    (testing "User not found"
      (testing-api (:GET (format nil "/users/~A" (generate-uuid)))
          (response)
        (ng (successp response))
        (ok (= (response-status response) 404))
        (ok (alist-match '(("type" . "notfound"))
                         (response-body response)))))))
