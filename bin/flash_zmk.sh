#!/usr/bin/env bash
set -e

SDK_VERSION="0.15.0"
# TODO: Default this better (assumes macOS)
SDK_OS_SUFFIX="_macos"
# TODO: Default this better (assumes macOS)
MOUNT_POINT="/Volumes/NICENANO"

KEYMAP="$1"

export ZEPHYR_TOOLCHAIN_VARIANT="zephyr"

// TODO: finish this... need to link directories and what not
VIBRAPHONE_GIT_DIR=`pwd`
pushd ./deps/zmk
  if [ ! -d "./app" ] ; then
    west init -l app/
  fi

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

pushd ./deps/zmk/app
  ZMK_APP_DIR=`pwd`
  west build -d build/left -b nice_nano_v2 -- -DSHIELD=${KEYMAP}_left \
    -DZMK_CONFIG="$VIBRAPHONE_GIT_DIR/config"
popd

until [ -d "$MOUNT_POINT" ]
do
  sleep 1
  echo "Waiting for $MOUNT_POINT to be mounted..."
done
echo "Flashing..."

cp "$ZMK_APP_DIR/build/left/zephyr/zmk.uf2" "$MOUNT_POINT"

until [ ! -d "$MOUNT_POINT" ]
do
  sleep 1
  echo "Waiting for $MOUNT_POINT to be unmounted..."
done

echo "Done flashing!"
