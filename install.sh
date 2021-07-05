#!/bin/sh

ROOT_DIR="$(realpath "$(dirname "$0")")";
. "${ROOT_DIR}/libs/functions.sh";

export ROOT_DIR;
export DEBIAN_FRONTEND=noninteractive;
export PATH="$PATH:/sbin:/usr/sbin";
export SUDO_CMD='sudo'
export LOG_FILE=/dev/stdout;

which sudo 2> /dev/null || SUDO_CMD='';
${SUDO_CMD} busybox touch $LOG_FILE;
${SUDO_CMD} sh "${ROOT_DIR}/libs/install_prereq.sh" install;

# Добавляем модуль 8021q в автозагрузку. Поддержка VLAN.
module_8021q=$(grep 8021q </etc/modules);
${SUDO_CMD} cat /etc/modules > /tmp/modules_miko;
if [ 'x' = "x${module_8021q}" ]; then 
	${SUDO_CMD} echo 8021q >> /tmp/modules_miko;
	${SUDO_CMD} mv /tmp/modules_miko /etc/modules;
fi;

for filename in "$ROOT_DIR"/packages/*.sh; do
  [ -e "$filename" ] || continue
  echo "Starting $filename";
  (
    ${SUDO_CMD} . "$filename";
  );
done

# Setting DNS
rm -rf /etc/resolv.conf;
ln -svi /run/systemd/resolve/resolv.conf /etc/resolv.conf
echo "[Resolve]" > /tmp/resolved.conf;
echo "DNS=127.0.0.1 4.4.4.4 8.8.8.8" >> /tmp/resolved.conf;
mv /tmp/resolved.conf /etc/systemd/resolved.conf;
systemctl enable systemd-resolved
systemctl restart systemd-resolved
# END Setting DNS

# Install MikoPBX source.
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
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

  ln -s /etc/rc/debian/mikopbx_lan_dhcp /etc/dhcp/dhclient-enter-hooks.d/mikopbx_lan_dhcp
)