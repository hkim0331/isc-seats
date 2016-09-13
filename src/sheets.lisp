(in-package :cl-user)
(defpackage sheets
  (:use :cl :cl-who :cl-mongo :cl-ppcre :hunchentoot))
(in-package :sheets)

(defvar *version* "0.3")

(cl-mongo:db.use "ucome")

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
        (:span "programmed by hkimura, release 0.3.")
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


;;; FIXME: polish up the code.
(define-easy-handler (form :uri "/form") ()
  (standard-page
      (:title "Sheet:form")
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

(define-easy-handler (check0 :uri "/check0") (year term wday hour room date)
  (standard-page
      (:title "Sheet:check")
    (:h3 "Sheets 0")
      (:p "year:" (str year))
      (:p "term:" (str term))
      (:p "wday:" (str (string= wday "Fri")))
      (:p "hour:" hour)
      (:p "room:" room)
      (:p "date:" date)
      (:p (:a :href "/form" "back"))))

;; tb001-tb082: 10.28.100.1-82
;; tb000:       10.28.100.200
;; tg001-tg100: 10.28.102.1-100
;; tg000:       10.28.102.200

;;; check は mongodb へのクエリーにすべきか？
(define-easy-handler (check :uri "/check") (year term wday hour room date)
  (let* ((ans0 (sheets (format nil "~a_~a" term year)
                     :uhour (format nil "~a~a" wday hour)
                     :date date))
         (pat (cond
                ((string= room "c-2b") "10.28.100")
                ((string= room "c-2g") "10.28.102")
                (t (error (format nil "unknown class room: ~a" room)))))
         (ans (remove-if-not #'(lambda (x) (scan pat (second x))) ans0)))
    (standard-page
        (:title "Sheet:check")
      (:h3 "Sheets")
      (:p "ans :" (format t "~a" ans))
      (:p (:a :href "/form" "back")))))



;; ((sid ip) ...) のリストを返したい。
;; このリストは上位関数で部屋番号 room でフィルタされる。
(defun sheets (col &key uhour date)
  (mapcar
   #'(lambda (x) (list (get-element "sid" x) (get-element "ip" x)))
   (docs (db.find col ($ ($ "uhour" uhour) ($ "date" date )) :limit 0))))


