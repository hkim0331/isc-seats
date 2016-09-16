(in-package :cl-user)
(defpackage seats
  (:use :cl :cl-who :cl-mongo :cl-ppcre :hunchentoot))
(in-package :seats)

;; misc. functions
(defun range (from &optional to step)
  "(range 4) => (0 1 2 3)
(range 1 4) => (1 2 3)
(range 1 10 2) => (1 3 5 7 9)"
  (labels ((R (from to step ret)
             (if (>= from to) (nreverse ret)
                 (R (+ from step) to step (cons from ret)))))
    (cond
      ((null to) (R 0 from 1 nil))
      ((null step) (R from to 1 nil))
      (t (R from to step nil)))))

(defun partition (xs)
  "(partition '(1 2 3 4)) => ((1 2) (2 3) (3 4))"
  (apply #'mapcar #'list (list xs (cdr xs))))

(defun transpose (list-of-list)
  "(transpose '((1 2 3) (a b c)) => ((1 a) (2 b) (3 c))"
     (apply #'mapcar #'list list-of-list))

(cl-mongo:db.use "test")

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
       (:link :type "text/css" :rel "stylesheet" :href "/seats.css"))
      (:body
       (:div :class "container"
        ,@body
        (:hr)
        (:span "programmed by hkimura.")
        (:script :src "https://code.jquery.com/jquery.js")
        (:script :src "https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"))))))

;; (use :hunchentoot) しない時、start はフルパスで hunchentoot:start のように。
(defun start-server (&optional (port 8080))
  (start (make-instance 'easy-acceptor :port port)))

;;; FIXME: polish up HTML form.
(define-easy-handler (form :uri "/form") ()
  (standard-page
      (:title "Seat:form")
    (:h3 "Select Class")
    (:form :method "post" :action "/check"
     (:table
      (:tr (:td "year") (:td (:input :name "year" :placeholder "2016")))
      (:tr (:td "term") (:td (:input :name "term")))
      (:tr (:td "wday") (:td (:input :name "wday")))
      (:tr (:td "hour") (:td (:input :name "hour")))
      (:tr (:td "room") (:td (:input :name "room")))
      (:tr (:td "date") (:td (:input :name "date"))))
     (:input :type "submit"))))


;; tb001-tb082: 10.28.100.1-82
;; tb000:       10.28.100.200
;; 各列の先頭:    1, 9, 17, 26, 35, 43, 51, 59, 67, 75, 83
;;
;; tg001-tg100:10.28.102.1-100
;; tg000:      10.28.102.200
;; 各列の先頭:   1, 13, 25, 37, 49, 61, 73, 87, 101

(defun make-seats (tops)
  (transpose (mapcar #'(lambda (xs) (apply #'range xs)) (partition tops))))

(defvar *c-2b* (make-seats '(1 9 17 26 35 43 51 59 67 75 83)))
(defvar *c-2g* (make-seats '(1 13 25 37 49 61 73 87 101)))

(defun seats-aux (col &key uhour date)
  "((ip sid) ...) のリストを返す。
  ip を端末番号に変えると ip でフィルタリングできなくなる。
  ip のままで。"
  (mapcar
   #'(lambda (x) (list (get-element "ip" x) (get-element "sid" x)))
   (docs (db.find col ($ ($ "uhour" uhour) ($ "date" date )) :limit 0))))

(defun seats (col &key uhour date room)
  (let ((ip
         (cond
           ((string= room "c-2b") "10.28.100")
           ((string= room "c-2g") "10.28.102")
           (t (error (format nil "unknown room ~a" room))))))
    (remove-if-not
     #'(lambda (e) (ppcre:scan ip (first e)))
     (seats-aux col :uhour uhour :date date))))

(define-easy-handler (check :uri "/check") (year term wday hour room date)
  (let* ((ans0 (seats (format nil "~a_~a" term year)
                     :uhour (format nil "~a~a" wday hour)
                     :date date))
         (pat (cond
                ((string= room "c-2b") "10.28.100")
                ((string= room "c-2g") "10.28.102")
                (t (error (format nil "unknown class room: ~a" room)))))
         (ans (remove-if-not #'(lambda (x) (scan pat (first x))) ans0)))
    (standard-page
        (:title "Sheet:check")
      (:h3 "Seats")
      (:p (format t "ans0: ~a" ans0))
      (:p (format t "ans: ~a" ans))
      (:p (:a :href "/form" "back")))))

