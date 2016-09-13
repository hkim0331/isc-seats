#|
  This file is a part of sheets project.
|#

(in-package :cl-user)
(defpackage sheets-asd
  (:use :cl :asdf))
(in-package :sheets-asd)

(defsystem sheets
  :version "0.3"
  :author "hiroshi.kimura.0331@gmail.com"
  :license "free"
  :depends-on (:cl-mongo
               :cl-ppcre
               :cl-who
               :hunchentoot)
  :components ((:module "src"
                :components
                ((:file "sheets")
                 (:file "seeds"))))
  :description "kyutech c-2b/c-2g sheet info. who sheets where?"
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
  :in-order-to ((test-op (test-op sheets-test))))
