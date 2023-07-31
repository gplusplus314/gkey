#!/usr/bin/env bash

empty_dirs=$(find ./deps -type d -empty)
if [[ -n "$empty_dirs" ]]; then
	git submodule update --init
fi

KEYMAP="$1"
if [ "$KEYMAP" == "vibraphone" ]; then
	./bin/build_zmk.sh "$KEYMAP"
elif [ "$KEYMAP" == "xylophone" ]; then
	./bin/build_qmk.sh "$KEYMAP"
else
	echo "unsupported keymap"
	exit 1
fi
