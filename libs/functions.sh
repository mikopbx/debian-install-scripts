#!/bin/bash
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

downloadFile()
{
	extensionUrl="$1";
	${SUDO_CMD} curl -LO "$extensionUrl";
	arName=$(basename "$extensionUrl");
	srcDirName=$(tar -tf "${PWD}/${arName}" | cut -f 1 -d '/' | sort -u | grep -v package.xml);
	${SUDO_CMD} tar xzf "${PWD}/${arName}"
  ${SUDO_CMD} rm -rf "${PWD}/${arName}";
  realpath "$srcDirName";
}

installPhpExtension()
{
	extensionName="$1";
	extensionUrl="$2";
	extensionPriority="$3";
	extensionPrefix="$4";
	extensionConfOpt="$5";

  srcDirName=$(downloadFile "$extensionUrl");
	makePhpExtension "${PWD}/${srcDirName}" "$extensionConfOpt"
	enablePhpExtension "$extensionName" "$extensionPriority" "$extensionPrefix" 
	${SUDO_CMD} rm -rf "${srcDirName}"
}

enablePhpExtension()
{
	libFileName="$1";
	priority="$2";
	prefix="$3";
	${SUDO_CMD} echo "${prefix}extension=${libFileName}.so" > "/tmp/${libFileName}.ini";
	${SUDO_CMD} rm -rf "/etc/php/$PHP_VERSION/mods-available/${libFileName}.ini" "/etc/php/$PHP_VERSION/fpm/conf.d/${priority}-${libFileName}.ini" "/etc/php/$PHP_VERSION/cli/conf.d/${priority}-${libFileName}.ini";
	${SUDO_CMD} mv "/tmp/${libFileName}.ini" "/etc/php/$PHP_VERSION/mods-available/${libFileName}.ini";

	links="$(find "/etc/php/$PHP_VERSION/cli/" -lname "/etc/php/$PHP_VERSION/mods-available/${libFileName}.ini")";
	if [ 'x' = "${links}x" ];then
    ${SUDO_CMD} ln -s "/etc/php/$PHP_VERSION/mods-available/${libFileName}.ini" "/etc/php/$PHP_VERSION/fpm/conf.d/${priority}-${libFileName}.ini";
    ${SUDO_CMD} ln -s "/etc/php/$PHP_VERSION/mods-available/${libFileName}.ini" "/etc/php/$PHP_VERSION/cli/conf.d/${priority}-${libFileName}.ini";
	fi
}

makePhpExtension()
{
	srcDirName="$1";
	confOptions="$2"
	(
	  cd "$srcDirName" || exit;
    {
      ${SUDO_CMD} phpize;
      ${SUDO_CMD} ./configure "$confOptions";
      ${SUDO_CMD} make;
      ${SUDO_CMD} make install;
    } >> "$LOG_FILE" 2>> "$LOG_FILE";
	)
}

export makePhpExtension enablePhpExtension installPhpExtension
