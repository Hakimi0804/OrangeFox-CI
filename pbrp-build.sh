#!/usr/bin/env bash

curl -sL https://raw.githubusercontent.com/noobyysauraj/telegram_bash_bot/master/util.sh -o util.sh
TOKEN=$BOT_TOKEN
source util.sh

# Constants
MANIFEST="https://github.com/PitchBlackRecoveryProject/manifest_pb.git"
MANIFEST_BRANCH="android-12.1"
DEVICE="RMX2001"
DT_LINK="https://github.com/PitchBlackRecoveryProject/android_device_realme_RMX2001-pbrp"
DT_BRANCH="android-12.1-cirrus"
DT_PATH="device/realme/RMX2001"

git config --global user.email "hakimifirdaus944@gmail.com"
git config --global user.name "Firdaus Hakimi"

df -h
mkdir work
cd work

repo init --depth=1 -u "$MANIFEST" -b "$MANIFEST_BRANCH"
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

git clone "$DT_LINK" --depth=1 --single-branch -b "$DT_BRANCH" "$DT_PATH"

# Add for the unified commit
mv device/realme/RMX2001/omni_{RM6785,RMX2001}.mk
sed -i 's/RM6785/RMX2001/g' device/realme/RMX2001/*.mk
sed -i 's/102760448/67108864/g' device/realme/RMX2001/BoardConfig.mk

. build/envsetup.sh && \
    lunch "omni_$DEVICE-eng" && \
    make -j8 pbrp
 
cd "out/target/product/$DEVICE"

curl -sL https://git.io/file-transfer | sh
file_link=$(./transfer --silent wet recovery.img)
tg --sendmsg -1001299514785 "$file_link"
tg --pinmsg -1001299514785 "$SENT_MSG_ID"
