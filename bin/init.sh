#!/usr/bin/env bash
set -e

pushd deps/qmk_firmware
git submodule update --init --recursive
qmk setup
popd
