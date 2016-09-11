#|
  This file is a part of sheets project.
|#

(in-package :cl-user)
(defpackage sheets-asd
  (:use :cl :asdf))
(in-package :sheets-asd)

(defsystem sheets
  :version "0.1"
  :author ""
  :license ""
  :depends-on (:cl-mongo
               :cl-who
               :hunchentoot)
  :components ((:module "src"
                :components
                ((:file "sheets"))))
  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op sheets-test))))
