#|
  This file is a part of seats project.
|#

(in-package :cl-user)
(defpackage seats-asd
  (:use :cl :asdf))
(in-package :seats-asd)

(defsystem seats
  :version "0.7.1"
  :author "hiroshi.kimura.0331@gmail.com"
  :license "free"
  :depends-on (:cl-mongo
               :cl-ppcre
               :cl-who
               :hunchentoot)
  :components ((:module "src"
                :components
                ((:file "seats")
                 (:file "seeds"))))
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
  :in-order-to ((test-op (test-op seats-test))))
