# seats requires mongodb works at 127.0.0.1:27017
# when no mongodb on localhost, port forward by 'make mongo'.

all: seats

seats:
	sbcl \
		--eval "(ql:quickload '(seats hunchentoot cl-who cl-mongo))" \
		--eval "(in-package :seats)" \
		--eval "(sb-ext:save-lisp-and-die \"seats\" :executable t :toplevel 'main)"
	@echo saved executable binary as 'seats'.
	@echo when install, 'static' folder must exist beside 'seats'.

clean:
	${RM} ./seats
	find ./ -name \*.bak -exec rm {} \;

# scripts for test
port-forward-mongodb:
	ssh -fN -L 27017:localhost:27017 hkim@dbs.melt.kyutech.ac.jp &

stop-port-forward:
	kill `ps ax | grep '[s]sh -fN -L 27017' | awk '{print $$1}'`

start: port-forward-mongodb
	./seats

