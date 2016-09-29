# seats requires mongodb works at 127.0.0.1:27017
# when no mongodb on localhost, port forward by 'make mongo'.

all: seats

seats:
	sbcl \
		--eval "(ql:quickload :seats)" \
		--eval "(in-package :seats)" \
		--eval "(sb-ext:save-lisp-and-die \"seats\" :executable t :toplevel 'main)"
	@echo saved executable binary as 'seats'.
	@echo when install, 'static' folder must exist beside 'seats'.

clean:
	${RM} ./seats
	find ./ -name \*.bak -exec rm {} \;

isc:
	install -m 0700 src/seats-isc.sh ${HOME}/bin/seats-start

