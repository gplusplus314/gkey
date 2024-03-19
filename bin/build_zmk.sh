#!/usr/bin/env bash
set -e

KEYMAP="$1"
if [ "$KEYMAP" == "vibraphone" ]; then
	BOARD="nice_nano_v2"
	# TODO: Default this better (assumes macOS)
else
	echo "unsupported keymap"
	exit 1
fi

SDK_VERSION="0.16.5-1"

os=$(uname)
if [[ "$os" == "Darwin" ]]; then
	SDK_OS_SUFFIX="_macos"
elif [[ "$os" == "Linux" ]]; then
	SDK_OS_SUFFIX="_linux"
else
	echo "Unsupported OS: $os"
	exit 1
fi

arch=$(uname -m)
if [[ "$arch" == "arm64" ]]; then
	SDK_ARCH="aarch64"
elif [[ "$arch" == "x86_64" ]]; then
	SDK_ARCH="x86_64"
else
	echo "Unsupported architecture: $arch"
fi

export ZEPHYR_TOOLCHAIN_VARIANT="zephyr"

REPO_DIR=$(pwd)
pushd deps/zmk
west init -l app/ || echo ""

if [ "$ZEPHYR_BASE" == "" ]; then
	mkdir -p ~/.local/opt
	pushd ~/.local/opt

	SDK_DIR="zephyr-sdk-$SDK_VERSION"

	if [ ! -d "$SDK_DIR" ]; then
		wget "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v$SDK_VERSION/zephyr-sdk-$SDK_VERSION$SDK_OS_SUFFIX-$SDK_ARCH.tar.xz"
		wget -O - "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v$SDK_VERSION/sha256.sum" | shasum --check --ignore-missing
		tar xvf "zephyr-sdk-$SDK_VERSION$SDK_OS_SUFFIX-$SDK_ARCH.tar.xz"
		rm "zephyr-sdk-$SDK_VERSION$SDK_OS_SUFFIX-$SDK_ARCH.tar.xz"
		pushd "zephyr-sdk-$SDK_VERSION"
		./setup.sh
		popd
	fi
	popd

	west update
	west zephyr-export
	source ./zephyr/zephyr-env.sh
fi
popd

if [ "$ZEPHYR_BASE" == "" ]; then
	echo "ZEPHYR_BASE is not set"
	exit 1
fi

pushd "firmware/zmk/$KEYMAP/config/boards/shields"
rm "$KEYMAP" || echo ""
ln -s "$REPO_DIR/keymaps/$KEYMAP" "$KEYMAP"
popd

mkdir -p out

pushd deps/zmk/app
ZMK_APP_DIR=$(pwd)
set +e
west build -c -p -d build/left -b "$BOARD" -- -DSHIELD=${KEYMAP}_left \
	-DZMK_CONFIG="$REPO_DIR/firmware/zmk/$KEYMAP/config"
cp "$ZMK_APP_DIR/build/left/zephyr/zmk.uf2" "../../../out/$KEYMAP.uf2"
#west build -c -p -d build/right -b "$BOARD" -- -DSHIELD=${KEYMAP}_right \
#	-DZMK_CONFIG="$REPO_DIR/firmware/zmk/$KEYMAP/config"
#cp "$ZMK_APP_DIR/build/right/zephyr/zmk.uf2" "../../../out/$KEYMAP.right.uf2"
STATUS="$?"
set -e
popd

pushd "firmware/zmk/$KEYMAP/config/boards/shields"
rm "$KEYMAP"
popd

exit "$STATUS"
