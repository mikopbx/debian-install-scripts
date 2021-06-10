#!/bin/bash

. "${ROOT_DIR}/libs/functions.sh";

LIB_VERSION='3.0.4';
LIB_URL="https://xdebug.org/files/xdebug-${LIB_VERSION}.tgz";
LIB_PRIORITY='50';
LIB_PHP_MODULE_PREFIX_INI='zend_';
LIB_CONFIGURE_OPTIONS='--enable-xdebug';
LIB_NAME='xdebug';

installPhpExtension "$LIB_NAME" "$LIB_URL" "$LIB_PRIORITY" "$LIB_PHP_MODULE_PREFIX_INI" "$LIB_CONFIGURE_OPTIONS"