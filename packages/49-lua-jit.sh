#!/bin/bash

LIB_VERSION='2.0.5';
LIB_URL="https://luajit.org/download/LuaJIT-${LIB_VERSION}.tar.gz"
srcDirName=$(downloadFile "$LIB_URL");
(
  cd "$srcDirName" || exit;
  {
    make;
    make install;
  } >> "$LOG_FILE" 2>> "$LOG_FILE";
)

rm -rf "$srcDirName";
