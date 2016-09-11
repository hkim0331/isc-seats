(in-package :cl-user)
(defpackage sheets
  (:use :cl :cl-who :cl-mongo :hunchentoot))
(in-package :sheets)

(defvar *version* 0.1)

(setf (html-mode) :html5)

(defmacro standard-page ((&key title) &body body)
  `(with-html-output-to-string
       (*standard-output* nil :prologue t :indent t)
     (:html
      :lang "ja"
      (:head
       (:meta :charset "utf-8")
       (:meta :http-equiv "X-UA-Compatible" :content "IE=edge")
       (:meta :name "viewport"
              :content "width=device-width, initial-scale=1.0")
       (:title ,title)
       (:link :rel "stylesheet"
              :href "//netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css")
       (:link :type "text/css" :rel "stylesheet" :href "/sheets.css"))
      (:body
       (:div :class "container"
        ,@body
        (:hr)
        (:span ,(format nil "programmed by hkimura, release ~a" *version*))
        (:script :src "https://code.jquery.com/jquery.js")
        (:script :src "https://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"))))))


(defun start-server (&optional (port 8080))
  (hunchentoot:start (make-instance 'easy-acceptor :port port)))
