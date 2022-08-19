#!/usr/bin/env bash

# Constants
MANIFEST="https://github.com/PitchBlackRecoveryProject/manifest_pb.git"
MANIFEST_BRANCH="android-11.0"
DEVICE="RMX2001"
DT_LINK="https://github.com/PitchBlackRecoveryProject/android_device_realme_RMX2001-pbrp"
DT_BRANCH="android-11.0"
DT_PATH="device/realme/RMX2001"

git config --global user.email "hakimifirdaus944@gmail.com"
git config --global user.name "Firdaus Hakimi"

df -h
mkdir work
cd work

repo init --depth=1 -u "$MANIFEST" -b "$MANIFEST_BRANCH"
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

git clone "$DT_LINK" --depth=1 --single-branch -b "$DT_BRANCH" "$DT_PATH"

. build/envsetup.sh && \
    lunch "omni_$DEVICE-eng" && \
    make -j8 pbrp

cd "out/target/product/$DEVICE"

curl -sL https://git.io/file-transfer | sh
./transfer wet recovery.img