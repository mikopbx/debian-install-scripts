#!/bin/bash

LIB_VERSION='7.4.6';
LIB_URL="https://www.php.net/distributions/php-${LIB_VERSION}.tar.gz";

srcDirName=$(downloadFile "$LIB_URL");
(
  cd "$srcDirName" || exit;
  {
    ./configure --prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --libdir=/lib64 --datadir=/usr/share --includedir=/usr/include --infodir=/usr/info --mandir=/usr/man --sysconfdir=/etc --localstatedir=/var --enable-shmop --enable-pcntl --enable-maintainer-zts --enable-fpm --with-zlib --with-bz2 --enable-bcmath --enable-mbstring --enable-sockets --with-gmp --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-openssl --with-gettext --with-libxml-dir --with-openssl --with-bz2=/usr --with-zip --with-pcre-regex=/usr --with-curl --with-libdir=lib64 --enable-opcache=yes;
    make;
    make install;
  } >> "$LOG_FILE" 2>> "$LOG_FILE";
)

rm -rf "$srcDirName";
