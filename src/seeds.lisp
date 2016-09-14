(in-package :seats)

(defparameter +year+ #(2016 2017))
(defparameter +term+ #("q1" "q2" "q3" "q4"))
(defparameter +sid+ #("hiroshi" "miyuki" "akari" "isana" "aoi"))
(defparameter +wday+ #("Mon" "Tue" "Wed" "Thr" "Fri"))
(defparameter +hour+ #(1 2 3 4 5))
(defparameter +date+ #("2016-09-14" "1985-10-26" "1962-04-20"))
(defun range (n)
  (labels ((R (n ret)
             (if (< n 0) ret
                 (R (- n 1) (cons n ret)))))
    (R n nil)))

(defparameter +c-2b+
  (apply #'vector
         (mapcar (lambda (n) (format nil "10.28.100.~a" n)) (range 100))))

(defparameter +c-2g+
  (apply #'vector
         (mapcar (lambda (n) (format nil "10.28.102.~a" n)) (range 100))))

(defun choose (v)
  (elt v (random (length v))))

;; (db.insert collection doc)
(defun seed (ip)
  (let ((year (choose +year+))
        (term (choose +term+))
        (sid (choose +sid+))
        (wday (choose +wday+))
        (hour (choose +hour+))
        (date (choose +date+))
        (ip (choose ip)))
    (cl-mongo:db.insert
     (format nil "~a_~a" term year)
     ($ ($ "sid" sid)
        ($ "uhour" (format nil "~a~a" wday hour))
        ($ "date" date)
        ($ "ip" ip)))))

(defun seeds (n)
  (dotimes (i n)
    (seed +c-2b+)
    (seed +c-2g+)))

