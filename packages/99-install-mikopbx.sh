#!/bin/bash

if [ "${MIKO_PBX_VERSION}x" = "x" ]; then
  MIKO_PBX_VERSION='dev-develop';
fi;

(
useradd www 2> /dev/null;
honeDir='/home/www';
mkdir -p "$honeDir" && chown www:www "$honeDir"
wwwDir='/usr/www';
mkdir -p "$wwwDir" && chown www:www "$wwwDir";
cd "$wwwDir" || exit;
su www -c "composer require mikopbx/core:${MIKO_PBX_VERSION}";
echo "${MIKO_PBX_VERSION}" > /etc/version;
busybox touch /etc/version.buildtime;
mv "$wwwDir/vendor/mikopbx/core/"* "$wwwDir/";
su www -c 'composer update';

echo "Installing gnatsd ..."
chmod +x "$wwwDir/resources/rootfs/usr/sbin/gnatsd"
ln -s "$wwwDir/resources/rootfs/usr/sbin/gnatsd" /usr/sbin/gnatsd;

rm -rf /etc/php.ini /etc/php.d/ /etc/nginx/ /etc/php-fpm.conf /etc/php-www.conf.;
ln -s $wwwDir/resources/rootfs/etc/nginx /etc/nginx
ln -s $wwwDir/resources/rootfs/etc/php.d /etc/php.d
ln -s $wwwDir/resources/rootfs/etc/php.ini /etc/php.ini
ln -s $wwwDir/resources/rootfs/etc/php-fpm.conf /etc/php-fpm.conf
ln -s $wwwDir/resources/rootfs/etc/php-www.conf /etc/php-www.conf
ln -s /bin/busybox /bin/killall

mkdir -p /cf/conf/;
chown -R www:www /cf
cp $wwwDir/resources/db/mikopbx.db /cf/conf/mikopbx.db

chown -R  asterisk:asterisk /etc/asterisk
mkdir -p /offload/rootfs/usr/www/ /offload/asterisk/;
ln -s /usr/lib/asterisk/modules/ /offload/asterisk/modules;
ln -s /var/lib/asterisk/documentation/ /offload/asterisk/documentation
ln -s /var/lib/asterisk/moh/ /offload/asterisk/moh;
mkdir -p /var/asterisk/run;
chown -R  asterisk:asterisk /var/asterisk/run;

ln -s /usr/www/config /etc/inc;
ln -s /usr/www/src/Core/Rc /etc/rc;
chmod +x -R /etc/rc;
chown -R www:www /offload;

mkdir -p /storage/usbdisk1 /storage/usbdisk1/mikopbx/media/moh /offload/asterisk/firmware/iax;
cp /usr/www/resources/sounds/moh/* /storage/usbdisk1/mikopbx/media/moh/

chmod +x /etc/rc/debian/*;
ln -s /etc/rc/debian/mikopbx.sh /etc/init.d/mikopbx;

extensionDir="$(php -i | grep '^extension_dir' | cut -d ' ' -f 3)";
ln -s /usr/www/resources/rootfs/usr/lib64/extensions/no-debug-zts-20190902/mikopbx.so "$extensionDir/mikopbx.so";
ln -s /usr/www/resources/sounds /offload/asterisk/sounds
chmod +x /usr/www/resources/rootfs/sbin/*;
ln -s /usr/www/resources/rootfs/sbin/wav2mp3.sh /sbin/wav2mp3.sh
ln -s /usr/www/resources/rootfs/sbin/crash_asterisk /sbin/crash_asterisk

ln -s /etc/rc/debian/mikopbx_iptables /etc/init.d/mikopbx-iptables

CTL_CMD='systemctl'
which "$CTL_CMD" 2> /dev/null || CTL_CMD='';
if [ ! "${CTL_CMD}x" = 'x' ]; then
  # в Docker нет systemctl
  ln -s /etc/rc/debian/mikopbx_lan_dhcp /etc/dhcp/dhclient-enter-hooks.d/mikopbx_lan_dhcp
  update-rc.d mikopbx defaults;
  systemctl restart mikopbx;
  update-rc.d mikopbx-iptables defaults
  systemctl disable rsyslog;
fi;

)
