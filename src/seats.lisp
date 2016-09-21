(in-package :cl-user)
(defpackage seats
  (:use :cl :cl-who :cl-mongo :cl-ppcre :hunchentoot))
(in-package :seats)

(defvar *version* "0.5.4")

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

;; FIXME, これではもっとも短いリストの長さを尊重する。
;; nil で埋めることはしない。まずいか？
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
       (:meta
        :charset "utf-8")
       (:meta
        :http-equiv "X-UA-Compatible"
        :content "IE=edge")
       (:meta
        :name "viewport"
        :content "width=device-width, initial-scale=1.0")
       (:link
        :rel "stylesheet"
        :href "/seats.css")
       (:link
        :rel "stylesheet"
        :href "//netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css")
       (:title ,title))
      (:body
       (:div :class "container"
        ,@body
        (:hr)
        (:span (format t "programmed by hkimura, ~a." *version*)))))))


(defmacro radios (name values)
  `(dolist (val ,values)
     (htm (:input :type "radio" :name ,name :value val (str val)))))

(define-easy-handler (index :uri "/index") ()
  (standard-page
      (:title "Seat:index")
    (:h3 "Select Class")
    (:form
     :method "post" :action "/check"
     (:table
      :id "selector"
      (:tr
       (:th "year")
       (:td (radios "year" '(2016 2017))))
      (:tr
       (:th "term")
       (:td (radios "term" '("q1" "q2" "q3" "q4"))))
      (:tr
       (:th "wday")
       (:td (radios "wday" '("Mon" "Tue" "Wed" "Thu" "Fri"))))
      (:tr
       (:th "hour")
       (:td (radios "hour" '(1 2 3 4 5))))
      (:tr
       (:th "room")
       (:td (radios "room" '("c-2b" "c-2g"))))
      (:tr
       (:th "date")
       (:td (:input :name "date" :placeholder "2016-09-14"))))
     (:br)
     (:input :type "submit"))))

;; c-2b: 10.28.100.1-82, 200
;; 各列の先頭:    1, 9, 17, 26, 35, 43, 51, 59, 67, 75, 83
;;
;; c-2g:10.28.102.1-100
;; 各列の先頭:   1, 13, 25, 37, 49, 61, 73, 87, 101
(defun make-seats (heads)
  (transpose
   (mapcar #'(lambda (xs) (apply #'range xs)) (partition heads))))

;; consider: 関数名。
(defun tables (room)
  (cond
    ((string= room "c-2b") (make-seats '(1 9 17 26 35 43 51 59 67 75 83)))
    ((string= room "c-2g") (make-seats '(1 13 25 37 49 61 73 87 101)))
    (t (error (format nil "unknown room ~a" room)))))

;; consider, seats の内部関数に？
(defun seats-aux (col &key uhour date)
  "((ip sid) ...) のリストを返す。
  ip を端末番号に変えると ip でフィルタリングできなくなる。
  ip のままで。"
  (mapcar
   #'(lambda (x) (list (get-element "ip" x) (get-element "sid" x)))
   (docs (db.find col ($ ($ "uhour" uhour) ($ "date" date )) :limit 0))))

(defun seats (col &key uhour date room)
  ;; use hash?
  (let ((ip
         (cond
           ((string= room "c-2b") "10.28.100")
           ((string= room "c-2g") "10.28.102")
           (t (error (format nil "unknown room ~a" room))))))
    (remove-if-not
     #'(lambda (e) (ppcre:scan ip (first e)))
     (seats-aux col :uhour uhour :date date))))

(defun name (n ip-name)
  "((ip name) ...) のリストから ip の第 4 オクテットが n であるものの名前を返す。"
  (cond
    ((null ip-name) " ")
    ((ppcre:scan (format nil "\\.~a$" n) (caar ip-name)) (cadar ip-name))
    (t (name n (cdr ip-name)))))

;;; FIXME:関数名を再考しよう。
(define-easy-handler (check :uri "/check") (year term wday hour room date)
  (let ((students (seats (format nil "~a_~a" term year)
                     :uhour (format nil "~a~a" wday hour)
                     :date date
                     :room room))
        (tables (tables room)))
    (standard-page
        (:title "Sheet:check")
      (:h3 (format t "~a_~a ~a~a ~a ~a" year term wday hour room date))
      (:p "↑ FRONT")
      (:div
       (:table
        :id "seats"
        (dolist (row tables)
          (htm (:tr
                (dolist (n row)
                  (htm (:td :class "seat"
                            (format t "~a" (name n students))))))))))
      (:p (:a :href "/index" "back")))))

;; server start/stop
;; check working directory.
(defun static-contents ()
  (push (create-static-file-dispatcher-and-handler
         "/seats.css" "static/seats.css") *dispatch-table*))

(defvar *http*)

(defun start-server (&optional (port 8080))
  (static-contents)
  (setf *http* (make-instance 'easy-acceptor :port port))
  (start *http*)
  (format t "server started at port ~a." port))

(defun stop-server ()
  (stop *http*))

(defun main ()
  (start-server 8081)
  (loop (sleep 60)))
