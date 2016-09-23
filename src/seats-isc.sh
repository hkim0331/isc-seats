#!/bin/sh
# quicklisp のパスが ${HOME}/lisp/src に通っていること。

cd ${HOME}/lisp/src/seats/src
ssh -fN -L 27017:localhost:27017 hkim@dbs.melt.kyutech.ac.jp &
sbcl --eval "(ql:quickload :seats)" \
     --eval "(in-package :seats)" \
     --eval "(start-server)"
kill `ps ax | grep '[s]sh -fN -L 27017' | awk '{print $1}'`




