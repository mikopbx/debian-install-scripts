#!/bin/bash

LIB_VERSION='2.1.2';
LIB_URL="https://github.com/msgpack/msgpack-php/archive/refs/tags/msgpack-${LIB_VERSION}.tar.gz";
LIB_PRIORITY='40';
LIB_PHP_MODULE_PREFIX_INI='';
LIB_CONFIGURE_OPTIONS='';
LIB_NAME='msgpack';

installPhpExtension "$LIB_NAME" "$LIB_URL" "$LIB_PRIORITY" "$LIB_PHP_MODULE_PREFIX_INI" "$LIB_CONFIGURE_OPTIONS"