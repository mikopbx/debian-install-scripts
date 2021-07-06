#!/bin/bash

LIB_VERSION='0.11';
LIB_URL_LUA_REST_CACHE="https://github.com/openresty/lua-resty-lrucache/archive/refs/tags/v${LIB_VERSION}.tar.gz";
srcDirNameLuaRestCache=$(downloadFile "$LIB_URL_LUA_REST_CACHE");
(
  cd "$srcDirNameLuaRestCache" || exit;
  export LUA_VERSION=5.1;
  make install;
)
rm -rf "$srcDirNameLuaRestCache"