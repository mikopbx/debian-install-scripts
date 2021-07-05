#!/bin/bash

LIB_VERSION='4.1.0';
LIB_URL="https://github.com/phalcon/cphalcon/archive/v${LIB_VERSION}.tar.gz";
LIB_PRIORITY='40';
LIB_PHP_MODULE_PREFIX_INI='';
LIB_NAME='phalcon';

curl -L 'https://github.com/zephir-lang/zephir/releases/download/0.12.21/zephir.phar' -o zephir;
chmod +x zephir;
srcDirName=$(downloadFile "$LIB_URL");
(
  cd "$srcDirName" || exit;
  {
    memLimit="$(grep memory_limit < /etc/php.ini)";
    if [ 'x' = "x${memLimit}" ]; then
      echo 'memory_limit=-1' >> /etc/php.ini;
    fi;
    ../zephir fullclean;
    ../zephir build;
    cp ./ext/modules/phalcon.so "$(php-config --extension-dir)/";
  } >> "$LOG_FILE" 2>> "$LOG_FILE";
)

rm -rf "$srcDirName" ./zephir;
enablePhpExtension "$LIB_NAME" "$LIB_PRIORITY" "$LIB_PHP_MODULE_PREFIX_INI"
