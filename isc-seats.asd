#|
  This file is a part of isc-seats project.
|#

(in-package :cl-user)
(defpackage isc-seats-asd
  (:use :cl :asdf))
(in-package :isc-seats-asd)

(defsystem isc-seats
  :version "0.7.1"
  :author "hiroshi.kimura.0331@gmail.com"
  :license "free"
  :depends-on (:cl-mongo
               :cl-ppcre
               :cl-who
               :hunchentoot)
  :components ((:module "src"
                :components
                ((:file "isc-seats")
                 (:file "isc-seats-seeds"))))
  :description "kyutech c-2b/c-2g seats info. who seats where?"
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.md"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op isc-seats-test))))
