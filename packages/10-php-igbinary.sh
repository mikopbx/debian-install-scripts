#!/bin/bash

. "${ROOT_DIR}/libs/functions.sh";

LIB_VERSION='3.2.1';
LIB_URL="https://github.com/igbinary/igbinary/archive/refs/tags/${LIB_VERSION}.tar.gz";
LIB_PRIORITY='40';
LIB_PHP_MODULE_PREFIX_INI='';
LIB_CONFIGURE_OPTIONS='';
LIB_NAME='igbinary';

installPhpExtension "$LIB_NAME" "$LIB_URL" "$LIB_PRIORITY" "$LIB_PHP_MODULE_PREFIX_INI" "$LIB_CONFIGURE_OPTIONS"
