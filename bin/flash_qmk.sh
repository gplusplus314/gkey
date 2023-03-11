#!/usr/bin/env bash
set -e

KEYMAP="$1"
if [ "$KEYMAP" == "xylophone" ] ; then
  KEYBOARD="cyboard/dactyl"
  LINK="cyboard"
  FW_FILE="cyboard_dactyl_$KEYMAP.uf2"
  # TODO: Default this better (assumes macOS)
  MOUNT_POINT="/Volumes/RPI-RP2"
else
  echo "unsuppored keymap"
  exit 1
fi

REPO_DIR=$(pwd)

pushd deps/qmk_firmware
  pushd keyboards
    ln -s "$REPO_DIR/firmware/qmk/keyboards/$LINK" "$LINK"
    pushd "$KEYBOARD/keymaps"
      ln -s "$REPO_DIR/keymaps/$KEYMAP" "$KEYMAP"
    popd
  popd

  set +e
  qmk compile -kb "$KEYBOARD" -km "$KEYMAP"

  pushd keyboards
    pushd "$KEYBOARD/keymaps"
      rm "$KEYMAP"
    popd
    rm "$LINK"
  popd
popd

mkdir -p out
mv "deps/qmk_firmware/$FW_FILE" "out/$KEYMAP.uf2"

echo "Firmware in: out/$KEYMAP.uf2"

until [ -d "$MOUNT_POINT" ]
do
  sleep 1
  echo "Waiting for $MOUNT_POINT to be mounted..."
done
echo "Flashing..."

cp "out/$KEYMAP.uf2" "$MOUNT_POINT"

until [ ! -d "$MOUNT_POINT" ]
do
  sleep 1
  echo "Waiting for $MOUNT_POINT to be unmounted..."
done

echo "Done flashing!"
