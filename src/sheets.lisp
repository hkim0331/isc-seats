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
              :href "//netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css")
       (:link :type "text/css" :rel "stylesheet" :href "/sheets.css"))
      (:body
       (:div :class "container"
        ,@body
        (:hr)
        (:span ,(format nil "programmed by hkimura, release ~a" *version*))
        (:script :src "https://code.jquery.com/jquery.js")
        (:script :src "https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"))))))

;; (use :hunchentoot) しない時、start は hunchentoot:start とフルパスで。
(defun start-server (&optional (port 8080))
  (start (make-instance 'easy-acceptor :port port)))

(define-easy-handler (hello :uri "/hello") ()
  (standard-page
      (:title "hello")
    (:h1 "Hello, World!")
    (:p (:a :href "http://www.melt.kyutech.ac.jp" "go melt")
        " or "
        (:a :href "/" "hunchentoot"))))

(define-easy-handler (form :uri "/form") ()
  (standard-page
      (:title "Sheet:form")
    (:h3 "Select Class 3")
    (:form :method "post" :action "check" :id "inputform"
     (:table
      (:tr (:td "year") (:td (:input :name "year" :placeholder "2016")))
      (:tr (:td "term") (:td (:input :name "term")))
      (:tr (:td "wday") (:td (:input :name "wday")))
      (:tr (:td "hour") (:td (:input :name "hour")))
      (:tr (:td "room") (:td (:input :name "room"))))
     (:input :type "submit"))))

;;; check は mongodb へのクエリーにすべきか？
(define-easy-handler (check :uri "/check") (year term wday hour room)
  (standard-page
      (:title "Sheet:check")
    (:h3 "Sheets 2")
    (:p (format t "~a ~a ~a ~a ~a" year term wday hour room))
    (:p (:a :href "/form" "back"))))
