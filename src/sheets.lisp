(in-package :cl-user)
(defpackage sheets
  (:use :cl :cl-who :cl-mongo :hunchentoot))
(in-package :sheets)

(defvar *version* "0.1")

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
        (:span ,(format nil "programmed by hkimura, release ~a"
                        "0.1"))
        (:script :src "https://code.jquery.com/jquery.js")
        (:script :src "https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"))))))

;; (use :hunchentoot) しない時、start はフルパスで hunchentoot:start のように。
(defun start-server (&optional (port 8080))
  (start (make-instance 'easy-acceptor :port port)))

(define-easy-handler (hello :uri "/hello") ()
  (standard-page
      (:title "hello")
    (:h1 "Hello, World!")
    (:p (:a :href "http://www.melt.kyutech.ac.jp" "go melt")
        " or "
        (:a :href "/" "hunchentoot"))))


;;; あとでポリッシュアップ。
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
  (let ((ans (find (format nil "~a_~a" term year)
                   :room room
                   :uhour (format nil "~a~a" wday hour))))
    (standard-page
        (:title "Sheet:check")
      (:h3 "Sheets 3")
      (:p ans.first)
      (:p (:a :href "/form" "back"))))

  )
;;; mongodb interface

;; prep dummy data.
;; tg001-tg100: 10.28.102.1-100
;; tg000:       10.28.102.200
;; tb001-tb082: 10.28.100.1-82
;; tb000:       10.28.100.200

(cl-mongo:db.use "ucome")

(defun range (n)
  (labels ((R (n ret)
             (if (< n 0) ret
                 (R (- n 1) (cons n ret)))))
    (R n nil)))

;; (db.insert collection doc)
(defun make-dummy-one (year term sid uhour date ip)
  (db.insert
   (format nil "~a_~a" term year)
   ($ ($ "sid" sid)
      ($ "uhour" uhour)
      ($ "icome" (format nil "[[ '~a' , '~a']]" date ip)))))

;;FIXME: make-dummy-one を2箇所で呼ぶのはださくね？
(defun make-dummy ()
  (dolist (year '(2016 2017))
    (dolist (term '("q3" "q4"))
      (dolist (wday '("Mon" "Tue" "Wed" "Thr" "Fri"))
        (dolist (hour '(1 2 3 4 5))
          (dolist (date '("2016-09-11" "2016-10-26" "1962-04-20"))
            (dolist (ip (range 80))
              (when (< (random 10) 2)
                (if (< (random 10) 5)
                    (make-dummy-one
                     year
                     term
                     (random 100)
                     (format nil "~a~a" wday hour)
                     date
                     (format nil "10.28.100.~a" ip))
                    (make-dummy-one
                     year
                     term
                     (random 100)
                     (format nil "~a~a" wday hour)
                     date
                     (format nil "10.28.102.~a" ip)))))))))))
