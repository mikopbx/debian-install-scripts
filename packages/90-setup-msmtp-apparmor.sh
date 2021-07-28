#!/bin/bash

ARMOR_CMD='apparmor_parser'
which "$ARMOR_CMD" 2> /dev/null || ARMOR_CMD='';
if [ ! "${ARMOR_CMD}x" = 'x' ]; then
  ln -s /etc/apparmor.d/usr.bin.msmtp /etc/apparmor.d/disable/
  apparmor_parser -R /etc/apparmor.d/usr.bin.msmtp
fi;