#!/bin/bash

(
useradd www;
honeDir='/home/www';
mkdir -p "$honeDir" && chown www:www "$honeDir"
wwwDir='/usr/www';
mkdir -p "$wwwDir" && chown www:www "$wwwDir";
cd "$wwwDir" || exit;
su www -c 'composer require mikopbx/core';
su www -c 'composer show -- mikopbx/core' | grep versions | cut -d ' ' -f 4 > /etc/version;
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

mkdir -p /storage/usbdisk1;

chmod +x /etc/rc/debian/*;
ln -s /etc/rc/debian/mikopbx.sh /etc/init.d/mikopbx;
update-rc.d mikopbx defaults;
systemctl restart mikopbx;

ln -s /etc/rc/debian/mikopbx_iptables  /etc/init.d/mikopbx-iptables
update-rc.d mikopbx-iptables defaults

ln -s /etc/rc/debian/mikopbx_lan_dhcp \
      /etc/dhcp/dhclient-enter-hooks.d/mikopbx_lan_dhcp
ln -s /usr/www/resources/rootfs/usr/lib64/extensions/no-debug-zts-20190902/mikopbx.so \
      /usr/lib64/extensions/no-debug-zts-20190902/mikopbx.so
ln -s /usr/www/resources/sounds /offload/asterisk/sounds
systemctl disable rsyslog;
)
