# seats requires mongodb works at 127.0.0.1:27017
# when no mongodb on localhost, port forward by 'make mongo'.

all: seats

seats:
	sbcl \
		--eval "(ql:quickload '(seats hunchentoot cl-who cl-mongo))" \
		--eval "(in-package :seats)" \
		--eval "(sb-ext:save-lisp-and-die \"src/seats\" :executable t :toplevel 'main)"
	@echo saved binary as src/seats.
	@echo 'static' folder must exist in the same folder of 'seat'.

mongo:
	ssh -fN -L 27017:localhost:27017 hkim@dbs.melt.kyutech.ac.jp &

clean:
	${RM} seats
	find ./ -name \*.bak -exec rm {} \;
