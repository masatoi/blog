(defpackage #:blog
  (:nicknames #:blog/main)
  (:use #:cl)
  (:import-from #:blog/config/application)
  (:import-from #:blog/config/routes))
(in-package #:blog)
