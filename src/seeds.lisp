(in-package :sheets)

(defun range (n)
  (labels ((R (n ret)
             (if (< n 0) ret
                 (R (- n 1) (cons n ret)))))
    (R n nil)))

;; (db.insert collection doc)
(defun make-dummy-one (year term sid uhour date ip)
  (cl-mongo:db.insert
   (format nil "~a_~a" term year)
   ($ ($ "sid" sid)
      ($ "uhour" uhour)
      ;; fix bug. not string, but list!
      ($ "icome" (list (list date ip))))))

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
;;(make-dummy)


