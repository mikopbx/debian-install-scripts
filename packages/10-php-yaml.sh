#!/bin/bash

. "${ROOT_DIR}/libs/functions.sh";

LIB_VERSION='2.0.4';
LIB_URL="https://github.com/php/pecl-file_formats-yaml/archive/${LIB_VERSION}.tar.gz";
LIB_PRIORITY='40';
LIB_PHP_MODULE_PREFIX_INI='';
LIB_CONFIGURE_OPTIONS='';
LIB_NAME='yaml';

installPhpExtension "$LIB_NAME" "$LIB_URL" "$LIB_PRIORITY" "$LIB_PHP_MODULE_PREFIX_INI" "$LIB_CONFIGURE_OPTIONS"