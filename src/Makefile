all: seats

seats: seats.lisp
	sbcl \
		--eval "(ql:quickload '(hunchentoot cl-who cl-mongo))" \
		--load $? \
		--eval "(in-package :seats)" \
		--eval "(sb-ext:save-lisp-and-die \"seats\" :executable t :toplevel 'main)"

clean:
	${RM} seats
