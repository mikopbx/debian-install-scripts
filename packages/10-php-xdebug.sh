#!/bin/bash

LIB_VERSION='2.9.5';
LIB_URL="https://xdebug.org/files/xdebug-${LIB_VERSION}.tgz";
LIB_PRIORITY='50';
LIB_PHP_MODULE_PREFIX_INI='zend_';
LIB_CONFIGURE_OPTIONS='--enable-xdebug';
LIB_NAME='xdebug';

installPhpExtension "$LIB_NAME" "$LIB_URL" "$LIB_PRIORITY" "$LIB_PHP_MODULE_PREFIX_INI" "$LIB_CONFIGURE_OPTIONS"