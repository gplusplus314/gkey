#!/usr/bin/env bash

set -x
set -e

KEYMAP="$1"
if [ "$KEYMAP" == "vibraphone" ]; then
	# TODO: Default this better (assumes macOS)
	MOUNT_POINT="/Volumes/NICENANO"
	RESET_FW="nicenanov2"
	FW_NAME="zmk.uf2"
elif [ "$KEYMAP" == "xylophone" ]; then
	# TODO: Default this better (assumes macOS)
	MOUNT_POINT="/Volumes/RPI-RP2"
	echo "no reset firmware configured for $KEYMAP"
	exit 1
else
	echo "unsupported keymap"
	exit 1
fi

until [ -d "$MOUNT_POINT" ]; do
	sleep 1
	echo "Waiting for $MOUNT_POINT to be mounted..."
done
echo "Flashing..."

cp "bin/firmware/$RESET_FW.uf2" "$MOUNT_POINT/$FW_NAME"

until [ ! -d "$MOUNT_POINT" ]; do
	sleep 1
	echo "Waiting for $MOUNT_POINT to be unmounted..."
done

echo "Done flashing!"
