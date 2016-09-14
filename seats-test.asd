#|
  This file is a part of seats project.
|#

(in-package :cl-user)
(defpackage seats-test-asd
  (:use :cl :asdf))
(in-package :seats-test-asd)

(defsystem seats-test
  :author ""
  :license ""
  :depends-on (:seats
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "seats"))))
  :description "Test system for seats"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
