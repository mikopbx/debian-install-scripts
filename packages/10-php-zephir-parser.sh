#!/bin/bash

LIB_VERSION='1.3.6';
LIB_URL="https://github.com/zephir-lang/php-zephir-parser/archive/refs/tags/v${LIB_VERSION}.tar.gz";
LIB_PRIORITY='20';
LIB_PHP_MODULE_PREFIX_INI='';
LIB_CONFIGURE_OPTIONS='';
LIB_NAME='zephir_parser';

installPhpExtension "$LIB_NAME" "$LIB_URL" "$LIB_PRIORITY" "$LIB_PHP_MODULE_PREFIX_INI" "$LIB_CONFIGURE_OPTIONS"