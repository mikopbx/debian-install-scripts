#!/bin/bash

. "${ROOT_DIR}/libs/functions.sh";

LIB_VERSION='6.2.1';
LIB_URL="https://download.redis.io/releases/redis-${LIB_VERSION}.tar.gz";
srcDirName=$(downloadFile "$LIB_URL");
(
  cd "$srcDirName" || exit;
  {
    make PREFIX=/;
    make install;
  } >> "$LOG_FILE" 2>> "$LOG_FILE";
)

rm -rf "$srcDirName" ./zephir;
