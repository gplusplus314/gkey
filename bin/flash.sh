#!/usr/bin/env bash

KEYMAP="$1"
if [ "$KEYMAP" == "vibraphone" ] ; then
  # TODO: Default this better (assumes macOS)
  MOUNT_POINT="/Volumes/NICENANO"
elif [ "$KEYMAP" == "xylophone" ] ; then
  # TODO: Default this better (assumes macOS)
  MOUNT_POINT="/Volumes/RPI-RP2"
else
  echo "unsupported keymap"
  exit 1
fi

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
