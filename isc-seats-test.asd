#|
  This file is a part of isc-seats project.
|#

(in-package :cl-user)
(defpackage isc-seats-test-asd
  (:use :cl :asdf))
(in-package :isc-seats-test-asd)

(defsystem isc-seats-test
  :author ""
  :license ""
  :depends-on (:isc-seats
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "isc-seats"))))
  :description "Test system for isc-seats"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
