# seats requires mongodb works at 127.0.0.1:27017
# when no mongodb on localhost, use port forward.

all: seats

isc-seats:
	sbcl \
		--eval "(ql:quickload :isc-seats)" \
		--eval "(in-package :isc-seats)" \
		--eval "(sb-ext:save-lisp-and-die \"isc-seats\" :executable t :toplevel 'main)"
	@echo saved executable binary as 'seats'.
	@echo when install, 'static' folder must exist beside 'seats'.

start: isc-seats
	nohup ./isc-seats &

stop:
	pkill isc-seats

restart:
	make stop
	make clean
	make start

clean:
	${RM} ./isc-seats
	find ./ -name \*.bak -exec rm {} \;

# isc:
# 	install -m 0700 src/seats-isc.sh ${HOME}/bin/seats-start

