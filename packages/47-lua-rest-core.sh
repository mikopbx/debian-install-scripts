#!/bin/bash

LIB_VERSION='0.1.22';

LIB_URL_LUA_REST="https://github.com/openresty/lua-resty-core/archive/refs/tags/v${LIB_VERSION}.tar.gz";
srcDirNameLuaRest=$(downloadFile "$LIB_URL_LUA_REST");
(
  cd "$srcDirNameLuaRest" || exit;
  {
    export LUA_VERSION=5.1;
    ln -s /usr/local/lib/lua/5.1/resty /usr/local/share/lua/5.1/resty;
    make install;
  }

)
rm -rf "$srcDirNameLuaRest"