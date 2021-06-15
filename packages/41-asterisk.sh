#!/bin/bash

. "${ROOT_DIR}/libs/functions.sh";
LIB_VERSION='16.16.2';
LIB_URL="http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${LIB_VERSION}.tar.gz";
LIB_NAME='asterisk';
srcDirName=$(downloadFile "$LIB_URL");
(
  cd "$srcDirName" || exit;
  {
    PATCH_PATH="${ROOT_DIR}/packages/patches/${LIB_NAME}";
    if [ -d "$PATCH_PATH" ]; then
      for filename in "$PATCH_PATH"/*.patch; do
        [ -e "$filename" ] || continue;
        echo "Starting $filename";
        (
          patch -p1 -i "$filename";
        );
      done
    fi;
    contrib/scripts/get_mp3_source.sh;
    ./configure;
    make menuselect.makeopts;
    menuselect/menuselect --enable app_meetme \
                          --enable format_mp3 \
                          --enable res_fax \
                          --enable app_macro \
                          --enable codec_opus \
                          --enable codec_silk \
                          --enable codec_siren7 \
                          --enable codec_siren14 \
                          --enable codec_g729a  \
                          --enable CORE-SOUNDS-RU-ALAW \
                          --enable CORE-SOUNDS-EN-ULAW menuselect.makeopts;
    adduser --system --group --home /var/lib/asterisk --no-create-home --disabled-password --gecos "MIKO PBX" asterisk;
    make;
    make install;
    make config;
    mkdir -p /storage/usbdisk1/mikopbx/persistence \
             /storage/usbdisk1/mikopbx/astlogs/asterisk \
             /storage/usbdisk1/mikopbx/voicemailarchive \
             /storage/usbdisk1/mikopbx/log/asterisk/;
    chown -R asterisk:asterisk /storage/usbdisk1/mikopbx/persistence \
             /storage/usbdisk1/mikopbx/astlogs/asterisk \
             /storage/usbdisk1/mikopbx/voicemailarchive \
             /storage/usbdisk1/mikopbx/log/asterisk/ \
             /etc/asterisk \
             /var/lib/asterisk \
             /var/spool/asterisk \
             /var/log/asterisk;
  } >> "$LOG_FILE" 2>> "$LOG_FILE";
)

rm -rf "$srcDirName" ./zephir;
