#!/bin/sh

if [ $# -ne 1 ]; then
	echo usage: $0 version
	exit 1;
fi

echo $0 > VERSION

