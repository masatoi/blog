(defsystem "blog"
  :class :package-inferred-system
  :author "Satoshi Imai"
  :version "0.0.1"
  :license "MIT"
  :description "simple web app scaffold"
  :depends-on ("blog/main")
  :in-order-to ((test-op (test-op "blog/tests"))))

(register-system-packages "lack-component" '(:lack.component))
(register-system-packages "lack-request" '(:lack.request))
(register-system-packages "lack-response" '(:lack.response))
(register-system-packages "lack-test" '(:lack.test))
