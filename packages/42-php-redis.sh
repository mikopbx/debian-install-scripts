#!/bin/bash

LIB_VERSION='5.3.4';
LIB_URL="https://github.com/phpredis/phpredis/archive/refs/tags/${LIB_VERSION}.tar.gz";
LIB_PRIORITY='50';
LIB_PHP_MODULE_PREFIX_INI='';
LIB_CONFIGURE_OPTIONS='--prefix=/ --enable-redis-igbinary --enable-redis-msgpack --enable-redis-lz --enable-redis-zstd';
LIB_NAME='redis';

installPhpExtension "$LIB_NAME" "$LIB_URL" "$LIB_PRIORITY" "$LIB_PHP_MODULE_PREFIX_INI" "$LIB_CONFIGURE_OPTIONS"