#!/usr/bin/env bash

set -o pipefail

curl -sL https://raw.githubusercontent.com/Hakimi0804/tgbot/main/util.sh -o util.sh
source util.sh

# Constants
MANIFEST="https://github.com/PitchBlackRecoveryProject/manifest_pb.git"
MANIFEST_BRANCH="android-12.1"
DEVICE="RMX2001"
DT_LINK="https://github.com/PitchBlackRecoveryProject/android_device_realme_RMX2001-pbrp"
DT_BRANCH="android-12.1"
DT_PATH="device/realme/RMX2001"
GOF_SERVER=$(curl -sL https://api.gofile.io/getServer | jq -r .data.server)
n=$'\n'

DEVICER7="RMX2151"
DT_LINKR7="https://github.com/PitchBlackRecoveryProject/android_device_realme_RMX2151-pbrp"
DT_BRANCHR7="android-12.1"
DT_PATHR7="device/realme/RMX2151"

CHAT_ID=-1001664444944
MSG_TITLE=(
    $'Building recovery for realme 6/RM6785\n'
)

git config --global user.email "hakimifirdaus944@gmail.com"
git config --global user.name "Firdaus Hakimi"

df -h
mkdir work
cd work

# Setup transfer
sh -c "$(curl -sL https://git.io/file-transfer)"

updateProg() {
    BUILD_PROGRESS=$(
            sed -n '/ ninja/,$p' "build_$DEVICE.log" | \
            grep -Po '\d+% \d+/\d+' | \
            tail -n1 | \
            sed -e 's/ / \(/' -e 's/$/)/'
        )
}

editProg() {
    if [ -z "$BUILD_PROGRESS" ]; then
        return
    fi
    if [ "$BUILD_PROGRESS" = "$PREV_BUILD_PROGRESS" ]; then
        return
    fi
    tg --editmsg "$CHAT_ID" "$SENT_MSG_ID" "${MSG_TITLE[*]}Progress: $BUILD_PROGRESS"
    PREV_BUILD_PROGRESS=$BUILD_PROGRESS
}

fail() {
    BUILD_PROGRESS=failed
    editProg
    exit 1
}

tg --sendmsg "$CHAT_ID" "${MSG_TITLE[*]}Progress: Syncing repo"

repo init --depth=1 -u "$MANIFEST" -b "$MANIFEST_BRANCH"
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)

git clone "$DT_LINK" --depth=1 --single-branch -b "$DT_BRANCH" "$DT_PATH"

MSG_TITLE+=($'\nBuilding for RMX2001\n')
. build/envsetup.sh && \
    lunch "omni_$DEVICE-eng" && \
    { make -j8 pbrp | tee -a "build_$DEVICE.log" || fail; } &

until [ -z "$(jobs -r)" ]; do
    updateProg
    editProg
    sleep 5
done

updateProg
editProg
file_link=$(curl -sL https://"${GOF_SERVER}".gofile.io/uploadFile -F file=@out/target/product/$DEVICE/recovery.img | jq -r .data.downloadPage)
MSG_TITLE+=("RMX2001 link: $file_link$n")




## REALME 7/Narzo 20 Pro/Narzo 30 4G ##

git clone "$DT_LINKR7" "$DT_PATHR7" --depth=1 --single-branch -b "$DT_BRANCHR7"

DEVICE=$DEVICER7
MSG_TITLE+=($'\nBuilding for RMX2151\n')
. build/envsetup.sh && \
    lunch "omni_$DEVICE-eng" && \
    { make -j8 pbrp | tee -a build_$DEVICE.log || fail; } &

until [ -z "$(jobs -r)" ]; do
    updateProg
    editProg
    sleep 5
done

updateProg
editProg

file_link=$(curl -sL https://"${GOF_SERVER}".gofile.io/uploadFile -F file=@out/target/product/$DEVICE/recovery.img | jq -r .data.downloadPage)
MSG_TITLE+=("RMX2151 link: $file_link$n")
BUILD_PROGRESS="Finished successfully"
editProg

nSENT_MSG_ID=$(tg --fwdmsg $CHAT_ID -1001299514785 $SENT_MSG_ID | jq .result.message_id)
tg --pinmsg -1001299514785  $nSENT_MSG_ID
