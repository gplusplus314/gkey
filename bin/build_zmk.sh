#!/usr/bin/env bash
set -e

KEYMAP="$1"
if [ "$KEYMAP" == "vibraphone" ] ; then
  BOARD="nice_nano_v2"
  # TODO: Default this better (assumes macOS)
  MOUNT_POINT="/Volumes/NICENANO"
else
  echo "unsupported keymap"
  exit 1
fi

SDK_VERSION="0.15.0"
# TODO: Default this better (assumes macOS)
SDK_OS_SUFFIX="_macos"

export ZEPHYR_TOOLCHAIN_VARIANT="zephyr"

REPO_DIR=$(pwd)
pushd deps/zmk
  west init -l app/ || echo ""

  if [ "$ZEPHYR_BASE" == "" ]; then
    mkdir -p ~/.local/opt
    pushd ~/.local/opt
      
      if [ ! -d "zephyr-sdk-$SDK_VERSION" ] ; then
        wget "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v$SDK_VERSION/zephyr-sdk-$SDK_VERSION$SDK_OS_SUFFIX-x86_64.tar.gz"
        wget -O - "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v$SDK_VERSION/sha256.sum" | shasum --check --ignore-missing
        tar xvf "zephyr-sdk-$SDK_VERSION$SDK_OS_SUFFIX-x86_64.tar.gz"
        rm "zephyr-sdk-$SDK_VERSION$SDK_OS_SUFFIX-x86_64.tar.gz"
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

pushd "firmware/zmk/$KEYMAP/config/boards/shields"
  ln -s "$REPO_DIR/keymaps/$KEYMAP" "$KEYMAP"
popd

pushd deps/zmk/app
  ZMK_APP_DIR=$(pwd)
  set +e
  west build -d build/left -b "$BOARD" -- -DSHIELD=${KEYMAP}_left \
    -DZMK_CONFIG="$REPO_DIR/firmware/zmk/$KEYMAP/config"
  set -e
popd

mkdir -p out

cp "$ZMK_APP_DIR/build/left/zephyr/zmk.uf2" "out/$KEYMAP.uf2"

pushd "firmware/zmk/$KEYMAP/config/boards/shields"
  rm "$KEYMAP"
popd

