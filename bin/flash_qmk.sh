#!/usr/bin/env bash
set -e

KEYMAP="$1"
if [ "$KEYMAP" == "xylophone" ] ; then
  KEYBOARD="cyboard/dactyl"
  LINK="cyboard"
else
  echo "unsuppored keymap"
  exit 1
fi

REPO_DIR=$(pwd)

pushd deps/qmk_firmware

pushd keyboards
  ln -s "$REPO_DIR/qmk/keyboards/$LINK" "$LINK"
  pushd "$KEYBOARD/keymaps"
    ln -s "$REPO_DIR/keymaps/$KEYMAP" "$KEYMAP"
  popd
popd

set +e
qmk compile -kb "$KEYBOARD" -km "$KEYMAP"
set -e

pushd keyboards
  pushd "$KEYBOARD/keymaps"
    rm "$KEYMAP"
  popd
  rm "$LINK"
popd

