#!/bin/sh
#
# MikoPBX - free phone system for small business
# Copyright © 2017-2021 Alexey Portnov and Nikolay Beketov
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program.
# If not, see <https://www.gnu.org/licenses/>.
#

imgName=$1;
if [ ! -f "$imgName" ]; then
  exit 1;
fi;

pathP1="/mnt/p1";
pathP2="/mnt/p2";
pathP3="/mnt/p3";
pathRoot="/mnt/mikopbx";

loopName=$(kpartx -a -v "${imgName}" | cut -d ' ' -f 3 | awk -F 'p'  '{print $1 "p" $2}' | uniq);
mkdir -p "$pathP1" "$pathP2" "$pathP3" "$pathRoot";
mount "/dev/mapper/${loopName}p1" "$pathP1";
mount "/dev/mapper/${loopName}p2" "$pathP2";
mount "/dev/mapper/${loopName}p3" "$pathP3";

# Распаковываем rootfs.
(
  cd "$pathRoot" || exit 3;
  zcat "$pathP1"/boot/initramfs.igz | cpio -i
)

mkdir -p "$pathRoot/dev/pts" \
		 "$pathRoot/dev/bus" \
		 "$pathRoot/tmp" \
		 "$pathRoot/ultmp" \
		 "$pathRoot/offload" \
		 "$pathRoot/cf/conf" \
		 "$pathRoot/var/etc" \
		 "$pathRoot/var/spool/cron" \
		 "$pathRoot/var/spool/cron/crontabs" \
		 "$pathRoot/etc/inc" \
		 "$pathRoot/var/lib/php/session";

chmod 777 /tmp
ln -s /offload/rootfs/usr "$pathRoot/usr";
ln -s /sys/bus/usb "$pathRoot/dev/bus/usb";
ln -s "/offload/rootfs/usr/www/src/Core/Rc" "$pathRoot/etc/rc"
cp -R "$pathP2/"* "$pathRoot/offload/";
cp "$pathRoot/conf.default/mikop bx.db" "$pathRoot/cf/conf/";
cp "$pathRoot/offload/rootfs/usr/www/config/mikopbx-settings.json" "$pathRoot/etc/inc/";
touch "$pathRoot/etc/docker";

(
  cd "$pathRoot" || exit 3;
  tar -c . | docker import - mikopbx:11
);
kpartx -d "${imgName}";
umount "/dev/mapper/${loopName}p1";
umount "/dev/mapper/${loopName}p2";
umount "/dev/mapper/${loopName}p3";
