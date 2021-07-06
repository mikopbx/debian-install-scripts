#!/bin/bash

LIB_VERSION='2.1-20210510';
LIB_URL="https://github.com/openresty/luajit2/archive/refs/tags/v${LIB_VERSION}.tar.gz"
srcDirName=$(downloadFile "$LIB_URL");
(
  cd "$srcDirName" || exit;
  {
    make;
    make install;
    ln -s /usr/local/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
    ln -s /usr/local/lib/libluajit-5.1.so.2 /usr/lib64/libluajit-5.1.so.2
  } >> "$LOG_FILE" 2>> "$LOG_FILE";
)

rm -rf "$srcDirName";
