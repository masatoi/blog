(defpackage #:blog/tests/functional/root/ping
  (:use #:cl
        #:rove
        #:blog/tests/utils))
(in-package #:blog/tests/functional/root/ping)

(deftest ping-tests
  (testing-api (:GET "/ping") (response)
    (ok (successp response))
    (ok (alist-match '(("pong" . "ok"))
                     (response-body response)))))
