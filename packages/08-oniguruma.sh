#!/bin/bash

LIB_VERSION='6.9.7.1';
LIB_URL="https://github.com/kkos/oniguruma/releases/download/v${LIB_VERSION}/onig-${LIB_VERSION}.tar.gz";

srcDirName=$(downloadFile "$LIB_URL");
(
  cd "$srcDirName" || exit;
  {
    autoreconf -vfi;
    ./configure;
    make;
    make install;
  } >> "$LOG_FILE" 2>> "$LOG_FILE";
)

rm -rf "$srcDirName";
