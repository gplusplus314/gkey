#!/usr/bin/env bash

KEYMAP="$1"
if [ "$KEYMAP" == "vibraphone" ] ; then
  ./bin/build_zmk.sh "$KEYMAP"
elif [ "$KEYMAP" == "xylophone" ] ; then
  ./bin/build_qmk.sh "$KEYMAP"
else
  echo "unsupported keymap"
  exit 1
fi
