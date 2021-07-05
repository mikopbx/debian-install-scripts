#!/bin/sh

ROOT_DIR="$(realpath "$(dirname "$0")")";
export ROOT_DIR;

VERSION='2021.1.148';
export PHP_VERSION='7.4';
export DEBIAN_FRONTEND=noninteractive;
export PATH="$PATH:/sbin:/usr/sbin";
. "${ROOT_DIR}/libs/functions.sh";
export SUDO_CMD='sudo'
which sudo 2> /dev/null || SUDO_CMD='';
export LOG_FILE=/dev/stdout;
${SUDO_CMD} busybox touch $LOG_FILE;
echo "Installing dependencies (install_prereq)...";
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
systemctl restart systemd-resolved
systemctl enable systemd-resolved
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
)


exit 0;

echo "Installing MIKOPBX ..."
# Добавим автозагрузку при старте:
if [ ! -d Core-$VERSION/etc/rc/mikopbx/ ]; then
	sudo mkdir -p Core-$VERSION/etc/rc;
	sudo mv mikopbx-systemd Core-$VERSION/etc/rc/mikopbx;
fi;

sudo cp -R Core-$VERSION/etc/rc/mikopbx /etc/rc;
sudo chmod +x /etc/rc/mikopbx/*;

sudo ln -s /etc/rc/mikopbx/mikopbx.sh /etc/init.d/mikopbx
sudo update-rc.d mikopbx defaults >> $LOG_FILE

sudo ln -s /etc/rc/mikopbx/mikopbx_iptables  /etc/init.d/mikopbx_iptables
sudo update-rc.d mikopbx_iptables defaults >> $LOG_FILE

sudo ln -s /etc/rc/mikopbx/mikopbx_lan_dhcp /etc/dhcp/dhclient-enter-hooks.d/mikopbx_lan_dhcp
sudo mkdir -p /storage/usbdisk1/mikopbx/log/system
sudo ln -s /var/log/messages /storage/usbdisk1/mikopbx/log/system/messages

sudo systemctl enable systemd-resolved >> $LOG_FILE
sudo systemctl enable pdnsd.service >> $LOG_FILE
sudo systemctl enable nginx.service >> $LOG_FILE
sudo systemctl disable ntp >> $LOG_FILE
sudo systemctl disable asterisk >> $LOG_FILE
sudo systemctl enable php$PHP_VERSION-fpm >> $LOG_FILE
sudo systemctl enable beanstalkd >> $LOG_FILE

sudo systemctl restart php$PHP_VERSION-fpm >> $LOG_FILE
sudo systemctl restart nginx.service >> $LOG_FILE
sudo systemctl restart beanstalkd >> $LOG_FILE

sudo systemctl restart mikopbx >> $LOG_FILE
sudo systemctl stop pdnsd >> $LOG_FILE
sudo systemctl start pdnsd >> $LOG_FILE
sudo systemctl restart systemd-resolved >> $LOG_FILE
