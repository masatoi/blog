(defpackage #:blog/tests
  (:use #:cl)
  (:import-from #:rove)
  (:import-from #:utopian)
  (:import-from #:mito)
  (:import-from #:blog)
  (:import-from #:blog/tests/functional)
  )
(in-package #:blog/tests)

(defmethod asdf:perform :after ((op asdf:test-op) (system (eql (asdf:find-system :blog/tests))))
  (rove:run system))
