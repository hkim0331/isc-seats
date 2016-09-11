#|
  This file is a part of sheets project.
|#

(in-package :cl-user)
(defpackage sheets-test-asd
  (:use :cl :asdf))
(in-package :sheets-test-asd)

(defsystem sheets-test
  :author ""
  :license ""
  :depends-on (:sheets
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "sheets"))))
  :description "Test system for sheets"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
