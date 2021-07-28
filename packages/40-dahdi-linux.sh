#!/bin/bash

LIB_VERSION='3.1.0';
LIB_URL="https://downloads.asterisk.org/pub/telephony/dahdi-linux/dahdi-linux-${LIB_VERSION}.tar.gz";
srcDirName=$(downloadFile "$LIB_URL");
(
  cd "$srcDirName" || exit;
  {
    make all;
    make install;
    insmod "$(modinfo dahdi | grep filename | awk -F ' ' ' { print $2} ')"
    insmod "$(modinfo dahdi_transcode | grep filename | awk -F ' ' ' { print $2} ')"
  } >> "$LOG_FILE" 2>> "$LOG_FILE";
)

rm -rf "$srcDirName" ./zephir;
