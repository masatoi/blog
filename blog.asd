(defsystem "blog"
  :class :package-inferred-system
  :author "Satoshi Imai"
  :version "0.0.1"
  :description "sample web app"
  :depends-on ("blog/main"))

(register-system-packages "lack-component" '(#:lack.component))
