(in-package :cl-user)
(defpackage isc-seats
  (:use :cl :cl-who :cl-mongo :cl-ppcre :hunchentoot))
(in-package :isc-seats)

(defvar *version* "0.7.1")

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

;; FIXME, このバージョンはもっとも短いリスト（席が少ない列）を尊重してしまう。
;; 長いリストを尊重し、nil で埋めた方がよい。
(defun transpose (list-of-list)
  "(transpose '((1 2 3) (a b c)) => ((1 a) (2 b) (3 c))"
  (apply #'mapcar #'list list-of-list))

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
       (:link :rel "stylesheet" :href "/isc-seats.css")
       (:link :rel "stylesheet"
        :href "//netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css")
       (:title ,title))
      (:body
       (:div :class "container"
        ,@body
        (:hr)
        (:span (format t "programmed by hkimura, ~a." *version*)))))))

(defmacro radio-buttons (name values)
  `(dolist (val ,values)
     (htm (:input :type "radio" :name ,name :value val (str val)))))

(define-easy-handler (index :uri "/index") ()
  (standard-page
      (:title "Seat:index")
    (:h3 "Select Class")
    (:form
     :method "post" :action "/show"
     (:table
      :id "selector"
      (:tr (:th "year") (:td (radio-buttons "year" '(2016 2017))))
      (:tr (:th "term") (:td (radio-buttons "term" '("q1" "q2" "q3" "q4"))))
      (:tr (:th "wday") (:td (radio-buttons "wday"
                                            '("Mon" "Tue" "Wed" "Thu" "Fri"))))
      (:tr (:th "hour") (:td (radio-buttons "hour" '(1 2 3 4 5))))
      (:tr (:th "room") (:td (radio-buttons "room" '("c-2b" "c-2g"))))
      (:tr (:th "date") (:td (:input :name "date" :placeholder "2016-09-14"))))
     (:br)
     (:input :type "submit" :value "show"))))

(defun find-desks (room)
  "c-2b: 10.27.100.1-82, 200
各列の先頭:    1, 9, 17, 26, 35, 43, 51, 59, 67, 75, 83
c-2g:10.27.102.1-100
各列の先頭:   1, 13, 25, 37, 49, 61, 73, 87, 101"
  (labels ((S (heads)
             (transpose
              (mapcar #'(lambda (xs) (apply #'range xs)) (partition heads)))))
    (cond
      ((string= room "c-2b") (S '(1 9 17 26 35 43 51 59 67 75 83)))
      ((string= room "c-2g") (S '(1 13 25 37 49 61 73 87 101)))
      (t (error (format nil "unknown room ~a" room))))))

(defun find-students (col &key uhour date room)
  (labels
      ((ip-sid (col &key uhour date)
         "((ip sid) ...) のリストを返す。"
         (mapcar
          #'(lambda (x) (list (get-element "ip" x) (get-element "sid" x)))
          (docs (db.find col
                         ($ ($ "uhour" uhour) ($ "date" date )) :limit 0)))))
    (let ((ip
           (cond
             ((string= room "c-2b") "10.27.100")
             ((string= room "c-2g") "10.27.102")
             (t (error (format nil "unknown room ~a" room))))))
      (remove-if-not
       #'(lambda (e) (ppcre:scan ip (first e)))
       (ip-sid col :uhour uhour :date date)))))

(defun find-sid (n ip-sid-list)
  "((ip sid) ...) のリストから ip の第 4 オクテットが n であるものの sid を返す。"
  (cond
    ((null ip-sid-list) " ")
    ((ppcre:scan (format nil "\\.~a$" n) (caar ip-sid-list))
     (cadar ip-sid-list))
    (t (find-sid n (cdr ip-sid-list)))))

(define-easy-handler (show :uri "/show") (year term wday hour room date)
  (let ((students (find-students (format nil "~a_~a" term year)
                     :uhour (format nil "~a~a" wday hour)
                     :date date
                     :room room))
        (desks (find-desks room)))
    (standard-page
        (:title "Sheet:show")
      (:h3 (format t "~a_~a ~a~a ~a ~a" year term wday hour room date))
      (:p "↑ FRONT")
      (:div
       (:table
        :id "isc-seats"
        (dolist (row desks)
          (htm (:tr
                (dolist (n row)
                  (htm (:td :class "seat"
                            (format t "~a" (find-sid n students))))))))))
      (:p (:a :href "/index" "back")))))

(defun static-contents ()
  (push (create-static-file-dispatcher-and-handler
         "/isc-seats.css" "static/isc-seats.css") *dispatch-table*))

(defvar *http*)

(defun start-server (&optional (port 8082))
  ;; production
  (cl-mongo:db.use "ucome")
  (static-contents)
  (setf *http* (make-instance 'easy-acceptor :port port))
  (start *http*)
  (format t "isc-seats start at http://localhost:~a/index" port))

(defun stop-server ()
  (stop *http*))

(defun main ()
  (start-server 20168)
  (loop (sleep 60)))
