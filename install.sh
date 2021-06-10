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
this_dir=$(pwd);

for filename in "$ROOT_DIR"/packages/*.sh; do
  [ -e "$filename" ] || continue
  echo "Starting $filename";
  (
    ${SUDO_CMD} sh "$filename";
  );
done

exit 0;

echo "Dounload source ...";
sudo curl -s 'http://files.miko.ru/s/rJh6mcSp1FeaPCw/download' -L -o src_pack.zip;
yes | sudo unzip src_pack.zip >> $LOG_FILE 2>> $LOG_FILE;
sudo rm -rf __MACOSX src_pack.zip;
SRC_DIR=$SRC_DIR/src_pack;
cd $SRC_DIR;
sudo curl -s "https://github.com/mikopbx/Core/archive/refs/tags/${VERSION}.zip" -o mikopbx.zip -L
yes | sudo unzip mikopbx.zip >> $LOG_FILE 2>> $LOG_FILE

echo "Setting beanstalkd ..."
sudo echo 'BEANSTALKD_LISTEN_ADDR=127.0.0.1' > /tmp/beanstalkd;
sudo echo 'BEANSTALKD_LISTEN_PORT=4229' >> /tmp/beanstalkd;
sudo mv /tmp/beanstalkd /etc/default/beanstalkd

cd dahdi-linux-complete-*;
echo "Build dahdi ...";
sudo make all >> $LOG_FILE 2>> $LOG_FILE;
sudo make install >> $LOG_FILE 2>> $LOG_FILE;
sudo make install-config >> $LOG_FILE 2>> $LOG_FILE;
cd ..

echo "Patch asterisk ..."
cd asterisk-16.*
cat ../asterisk-pack/patch/miko_asterisk_16_9_0.patch | sudo patch -p1 >> $LOG_FILE 2>> $LOG_FILE;

echo "Start contrib/scripts/* ..."
yes | sudo contrib/scripts/get_mp3_source.sh  >> $LOG_FILE 2>> $LOG_FILE;
# yes | sudo contrib/scripts/install_prereq install  >> $LOG_FILE 2>> $LOG_FILE;

echo "Configure asterisk ..."
sudo ./configure >> $LOG_FILE 2>> $LOG_FILE;
sudo adduser --system --group --home /var/lib/asterisk --no-create-home --disabled-password --gecos "MIKO PBX" asterisk >> $LOG_FILE 2>> $LOG_FILE;

sudo make menuselect.makeopts >> $LOG_FILE 2>> $LOG_FILE;
sudo menuselect/menuselect --enable app_meetme \
--enable format_mp3 \
--enable app_macro \
--enable codec_opus \
--enable codec_silk \
--enable codec_siren7 \
--enable codec_siren14 \
--enable codec_g729a  \
--enable CORE-SOUNDS-RU-ALAW \
--enable CORE-SOUNDS-EN-ULAW menuselect.makeopts; # */

echo "Build asterisk ..."
sudo make >> $LOG_FILE 2>> $LOG_FILE;
sudo make install >> $LOG_FILE 2>> $LOG_FILE;
sudo make config >> $LOG_FILE 2>> $LOG_FILE;

sudo mkdir -p /storage/usbdisk1/mikopbx/persistence /storage/usbdisk1/mikopbx/astlogs/asterisk /storage/usbdisk1/mikopbx/voicemailarchive /storage/usbdisk1/mikopbx/log/asterisk/
sudo chown -R asterisk:asterisk /storage/usbdisk1/mikopbx/persistence /storage/usbdisk1/mikopbx/astlogs/asterisk /storage/usbdisk1/mikopbx/voicemailarchive /storage/usbdisk1/mikopbx/log/asterisk/
sudo chown -R asterisk:asterisk /etc/asterisk /var/lib/asterisk /var/spool/asterisk /var/log/asterisk
cd ..;

echo "Installing nginx..."
sudo apt-get purge apache2 -y >> $LOG_FILE 2>> $LOG_FILE;

sudo useradd www;
cd nginx-pack;
sudo dpkg -i nginx-common_1.14.2-2+deb10u1miko1_all.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-http-auth-pam*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-http-dav-ext*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-http-echo*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-http-geoip*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-http-image-filter*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-http-subs-filter*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-http-upstream-fair*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-http-xslt-filter*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-mail*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-stream*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-http-ndk*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i libnginx-mod-http-lua*.deb >> $LOG_FILE 2>> $LOG_FILE;
sudo dpkg -i nginx-full*.deb >> $LOG_FILE 2>> $LOG_FILE;
cd ..;

echo "Installing pdnsd ..."
cd pdnsd;
sudo cp pdnsd.conf /etc/pdnsd.conf
# echo -ne '\n' | apt-get install -y libvpb-dev
yes '' | sudo dpkg -i pdnsd_1.2.9a-par-2miko1_amd64.deb >> $LOG_FILE 2>> $LOG_FILE;
# sudo mkdir -p /storage/usbdisk1/mikopbx/log/pdnsd/cashe;
# sudo chown pdnsd /storage/usbdisk1/mikopbx/log/pdnsd/cashe;

#sudo echo 'START_DAEMON=yes' > /tmp/pdnsd;
#sudo echo 'AUTO_MODE=' >> /tmp/pdnsd;
#sudo echo 'START_OPTIONS=' >> /tmp/pdnsd;
# sudo mv /tmp/pdnsd /etc/default/pdnsd

sudo rm -rf /etc/resolv.conf;
sudo ln -svi /run/systemd/resolve/resolv.conf /etc/resolv.conf;

echo "[Resolve]" > /tmp/resolved.conf;
echo "DNS=127.0.0.1" >> /tmp/resolved.conf;
sudo mv /tmp/resolved.conf /etc/systemd/resolved.conf;
sudo systemctl restart systemd-resolved
sudo systemctl restart pdnsd
cd ..;

echo "Installing gnatsd ..."
sudo chmod +x gnatsd 
sudo mv gnatsd /usr/sbin/gnatsd

echo "Installing MIKOPBX ..."
sudo mkdir -p /var/etc/;
sudo echo $VERSION > /tmp/version;
sudo mv /tmp/version /etc/version;
sudo busybox touch /etc/version.buildtime;

sudo rm -rf /etc/php/$PHP_VERSION/fpm/pool.d/*; #*/

sudo cp Core-$VERSION/etc/php-www.conf /etc/php/$PHP_VERSION/fpm/pool.d/;
sudo cp Core-$VERSION/etc/nginx/nginx.conf /etc/nginx/nginx.conf.pattern;
sudo sed -i '1s/^/load_module modules\/ngx_http_lua_module.so;\n/' /etc/nginx/nginx.conf.pattern;
sudo sed -i '1s/^/load_module modules\/ndk_http_module.so;\n/' /etc/nginx/nginx.conf.pattern;
sudo cp /etc/nginx/nginx.conf.pattern /etc/nginx/nginx.conf;
sudo sed -i 's/<WEBPort>/80/g' /etc/nginx/nginx.conf;

php_ini_file='php_miko.ini';
sudo echo 'include_path = ".:/etc/inc:/usr/www:/etc/asterisk/agi-bin"' > "/tmp/${php_ini_file}";
sudo echo 'session.save_path = /var/lib/php/session' >> "/tmp/$php_ini_file";
sudo echo 'error_log = /var/log/php_error.log' 	  >> "/tmp/$php_ini_file";
sudo echo 'upload_max_filesize = 100G' 	  >> "/tmp/$php_ini_file";
sudo echo 'post_max_size = 100G' 	  >> "/tmp/$php_ini_file";
sudo echo 'default_charset = "UTF-8"' 	  >> "/tmp/$php_ini_file";

sudo mv "/tmp/$php_ini_file" "/etc/php/$PHP_VERSION/mods-available/${php_ini_file}";
sudo ln -s "/etc/php/$PHP_VERSION/mods-available/${php_ini_file}" "/etc/php/$PHP_VERSION/fpm/conf.d/40-${php_ini_file}";
sudo ln -s "/etc/php/$PHP_VERSION/mods-available/${php_ini_file}" "/etc/php/$PHP_VERSION/cli/conf.d/40-${php_ini_file}";

sudo rm -rf  /etc/asterisk/*;
sudo cp -R Core-$VERSION/etc/asterisk/* /etc/asterisk/
sudo chown -R  asterisk:asterisk /etc/asterisk/*

sudo mkdir -p /offload/rootfs/usr/www/ /offload/asterisk/;
sudo ln -s /usr/lib/asterisk/modules/ /offload/asterisk/modules
sudo ln -s /var/lib/asterisk/documentation/ /offload/asterisk/documentation
sudo ln -s /var/lib/asterisk/moh/ /offload/asterisk/moh
sudo mkdir -p /var/asterisk/run
sudo chown -R  asterisk:asterisk /var/asterisk/run

sudo ln -s /offload/rootfs/usr/www/ /usr/www;
sudo cp -r Core-$VERSION/www/* /offload/rootfs/usr/www/;
sudo cp -r Core-$VERSION/etc/inc /etc/;
sudo cp -R Core-$VERSION/etc/rc /etc/
sudo chmod +x -R /etc/rc
sudo chown -R www:www /offload;
sudo mkdir -p /cf/conf/

sudo cp mikopbx.db /cf/conf/mikopbx.db;
sudo chown -R www:www /cf/conf/

# Накладываем патч. Если необходимо. 
if [ -f $SRC_DIR/mikopbx-patches/mikopbx_$VERSION.patch ]; then
	cd /;
	sudo cat $SRC_DIR/mikopbx-patches/mikopbx_$VERSION.patch | sudo patch -p0;
	cd  $SRC_DIR;
fi

### nginx ищет файлы тут /offload/rootfs/usr/www/admin-cabinet/public/js/cache
### файлы должны лежать тут /storage/usbdisk1/mikopbx/cache_js_dir
sudo rm -rf /offload/rootfs/usr/www/admin-cabinet/public/js/cache;
sudo ln -s /storage/usbdisk1/mikopbx/cache_js_dir /offload/rootfs/usr/www/admin-cabinet/public/js/cache;

sudo rm -rf /offload/rootfs/usr/www/admin-cabinet/public/css/cache;
sudo ln -s /storage/usbdisk1/mikopbx/cache_css_dir /offload/rootfs/usr/www/admin-cabinet/public/css/cache;

sudo rm -rf /offload/rootfs/usr/www/admin-cabinet/public/img/cache
sudo ln -s  /storage/usbdisk1/mikopbx/cache_img_dir /offload/rootfs/usr/www/admin-cabinet/public/img/cache

sudo mkdir -p /storage/usbdisk1/;
sudo mkdir -p /var/cache/www/admin-cabinet/cache/volt/ /var/cache/www/back-end/cache/metadata/ /var/cache/www/back-end/cache/datacache/ /var/log/www/admin-cabinet/logs/
sudo chown -R www:www /var/cache/www/admin-cabinet/cache/volt/ /var/cache/www/back-end/cache/metadata/ /var/cache/www/back-end/cache/datacache/ /var/log/www/admin-cabinet/logs/

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

cd $this_dir;
sudo rm -rf $SRC_DIR/*;
# sudo sed -i 's/root:\/bin\/bash/root:\/etc\/rc\/initial/g' /etc/passwd;

sudo systemctl enable systemd-resolved >> $LOG_FILE
sudo systemctl enable pdnsd.service >> $LOG_FILE
sudo systemctl enable nginx.service >> $LOG_FILE
sudo systemctl disable ntp  >> $LOG_FILE
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
