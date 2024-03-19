#!/usr/bin/env bash

KEYMAP="$1"
if [ "$KEYMAP" == "vibraphone" ]; then
	MOUNT_NAME="NICENANO"
elif [ "$KEYMAP" == "vibraphone.right" ]; then
	MOUNT_NAME="NICENANO"
elif [ "$KEYMAP" == "xylophone" ]; then
	MOUNT_NAME="RPI-RP2"
else
	echo "unsupported keymap"
	exit 1
fi

os=$(uname)
if [[ "$os" == "Darwin" ]]; then
	MOUNT_POINT="/Volumes/$MOUNT_NAME"
elif [[ "$os" == "Linux" ]]; then
	MOUNT_POINT="/run/media/$USER/$MOUNT_NAME"
else
	echo "Unsupported OS: $os"
	exit 1
fi

until [ -d "$MOUNT_POINT" ]; do
	sleep 1
	echo "Waiting for $MOUNT_POINT to be mounted..."
done
echo "Flashing..."

cp "out/$KEYMAP.uf2" "$MOUNT_POINT"

until [ ! -d "$MOUNT_POINT" ]; do
	sleep 1
	echo "Waiting for $MOUNT_POINT to be unmounted..."
done

echo "Done flashing!"
