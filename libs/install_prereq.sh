#! /bin/bash
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

#
# $Id$
#

# install_prereq: a script to install distribution-specific
# prerequirements

set -e

if [ 'x' = "x${PHP_VERSION}" ]; then 
  PHP_VERSION='7.4';
fi;

usage() {
	echo "$0: a script to install distribution-specific prerequirement"
	echo ""
	echo "Usage: $0:                    Shows this message."
	echo "Usage: $0 test                Prints commands it is about to run."
	echo "Usage: $0 install             Really install."
	echo "Usage: $0 install-unpackaged  Really install unpackaged requirements."
}

# Basic build system:
PACKAGES_DEBIAN="curl dialog build-essential pkg-config"
# Asterisk: basic requirements:
PACKAGES_DEBIAN="$PACKAGES_DEBIAN libedit-dev libjansson-dev libsqlite3-dev uuid-dev libxml2-dev"
# Asterisk: for addons:
PACKAGES_DEBIAN="$PACKAGES_DEBIAN libspeex-dev libspeexdsp-dev libogg-dev libvorbis-dev libasound2-dev portaudio19-dev libcurl4-openssl-dev xmlstarlet bison flex"
PACKAGES_DEBIAN="$PACKAGES_DEBIAN libpq-dev unixodbc-dev libneon27-dev libgmime-2.6-dev liblua5.2-dev liburiparser-dev libxslt1-dev libssl-dev"
PACKAGES_DEBIAN="$PACKAGES_DEBIAN libbluetooth-dev libradcli-dev freetds-dev libosptk-dev libjack-jackd2-dev bash"
PACKAGES_DEBIAN="$PACKAGES_DEBIAN libsnmp-dev libiksemel-dev libcorosync-common-dev libcpg-dev libcfg-dev libnewt-dev libpopt-dev libical-dev libspandsp-dev"
PACKAGES_DEBIAN="$PACKAGES_DEBIAN libresample1-dev libc-client2007e-dev binutils-dev libsrtp2-dev libsrtp2-dev libgsm1-dev doxygen graphviz zlib1g-dev libldap2-dev"
PACKAGES_DEBIAN="$PACKAGES_DEBIAN libcodec2-dev libfftw3-dev libsndfile1-dev libunbound-dev"
# Asterisk: for the unpackaged below:
PACKAGES_DEBIAN="$PACKAGES_DEBIAN wget subversion"
# Asterisk: for ./configure --with-pjproject-bundled:
PACKAGES_DEBIAN="$PACKAGES_DEBIAN bzip2 patch python-dev vlan git ntp sqlite3 curl w3m re2c lame"
PACKAGES_DEBIAN="$PACKAGES_DEBIAN fail2ban sngrep tcpdump msmtp beanstalkd lua5.1-dev liblua5.1-0 libtonezone-dev libevent-dev libyaml-dev"
PACKAGES_DEBIAN="$PACKAGES_DEBIAN php${PHP_VERSION} php${PHP_VERSION}-mbstring php${PHP_VERSION}-fpm php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-curl"
PACKAGES_DEBIAN="$PACKAGES_DEBIAN php${PHP_VERSION}-dev php${PHP_VERSION}-yaml php${PHP_VERSION}-bcmath "
PACKAGES_DEBIAN="$PACKAGES_DEBIAN linux-headers-$(uname -r)"

JANSSON_VER=2.12

case "$1" in
test)
	testcmd='echo';
	;;
install)
	testcmd=''
	;;
install-unpackaged)
	unpackaged="yes"
	;;
'')
	usage
	exit 0
	;;
*)
	usage
	exit 1
	;;
esac

check_installed_debs() {
	for pack in "$@" ; do
		tocheck="${tocheck} ^${pack}$ ~P^${pack}$"
	done

	pkgs=$(aptitude -F '%c %p' search "${tocheck}" 2>/dev/null | awk '/^p/{print $2}')
	
	echo "$pkgs";
	if [ ${#pkgs} -ne 0 ]; then
		echo "$pkgs" | sed -r -e "s/ ?[^ :]+:i386//g"
	fi
}

check_installed_equery() {
	for pack in "$@"
	do
		pack_with_version="${pack/:/-}" # replace a possible version with '-'
		if ! ls -d "/var/db/pkg/${pack_with_version}"* >/dev/null 2>/dev/null
		then echo "$pack"
		fi
	done
}
# Create ProgressBar function
# Input is currentState($1) and totalState($2)
ProgressBar() {
	# Process data
  _progress=$(echo "scale=1; 100*${1}/${2}" | busybox bc | sed -e 's/^\./0./' -e 's/^-\./-0./');
  _done=$(echo "scale=1; 4*${_progress}/10" | busybox bc);
  _left=$(echo "scale=1; 40 - $_done" | busybox bc);

	# Build progressbar string lengths
  _fill=$(printf "%${_done}s" | tr ' ' '#')
  _empty=$(printf "%${_left}s")
	
	# Build progressbar strings and print the ProgressBar line
	# shellcheck disable=SC2183
	printf "\r%150s";

	printf "\rProgress : [${_fill}${_empty}] ${_progress}%%. Now installing \e[1;32m${3}\e[0m. "
}

handle_debian() {
	apt -y install lsb-release apt-transport-https ca-certificates > /dev/null 2> /dev/null;
	phpListFile='/etc/apt/sources.list.d/php.list';
	if [ ! -f "$phpListFile" ]; then
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee "$phpListFile"
  fi;
	if ! [ -x "$(command -v aptitude)" ]; then
		apt-get install -y aptitude > /dev/null
	fi

	extra_packs=$(check_installed_debs "$PACKAGES_DEBIAN")
	apt-get update > /dev/null
	if [ x"$extra_packs" != "x" ] ; then
			count_words=$(echo "$extra_packs" | wc -w);
			i=0
			for deb_pack in $extra_packs
			do
				i=$((i + 1));
				ProgressBar "${i}" "${count_words}" "${deb_pack}";
				# shellcheck disable=SC2039
				echo -ne '\n' | apt-get install -y "$deb_pack" > /dev/null 2> /dev/null
			done
	fi
}

install_unpackaged() {
	echo "*** Installing NBS (Network Broadcast Sound) ***"
	svn co http://svn.digium.com/svn/nbs/trunk nbs-trunk
	cd nbs-trunk
	make all install
	cd ..

	# Only install libresample if it wasn't installed via package
	if ! test -f /usr/include/libresample.h; then
		echo "*** Installing libresample ***"
		svn co http://svn.digium.com/svn/thirdparty/libresample/trunk libresample-trunk
		cd libresample-trunk
		./configure
		make all install
		cd ..
	fi

	# Only install Jansson if it wasn't installed via package
	if ! test -f /usr/include/jansson.h; then
		echo "*** Installing jansson ***"
		wget -O - http://www.digip.org/jansson/releases/jansson-${JANSSON_VER}.tar.gz | zcat | tar -xf -
		cd jansson-${JANSSON_VER}
		./configure
		make all install
		cd ..
		if test -d /etc/ld.so.conf.d; then
			echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local.conf
		else # for example: Slackware 14.2
			echo "/usr/local/lib" > /etc/ld.so.conf
		fi
		/sbin/ldconfig
	fi

	# Only install libsrtp2 if it wasn't installed via package
	if ! test -f /usr/include/srtp/srtp.h; then
		if ! test -f /usr/include/srtp2/srtp.h; then
			echo "*** Installing libsrtp2 ***"
			wget -O - http://github.com/cisco/libsrtp/archive/v2.tar.gz | zcat | tar -xf -
			cd libsrtp-2
			./configure --enable-openssl
			make shared_library install
			cd ..
			if test -d /etc/ld.so.conf.d; then
				echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local.conf
			else # for example: Slackware 14.2
				echo "/usr/local/lib" > /etc/ld.so.conf
			fi
			/sbin/ldconfig
		fi
	fi

	if ! test -f /usr/include/pjlib.h; then
		echo "PJProject not installed, yet. Therefore, please, run"
		echo "./configure --with-pjproject-bundled"
	fi
}

if test "${unpackaged}" = "yes" ; then
	install_unpackaged
	exit 0
fi

OS=$(uname -s);
unsupported_distro='';

# A number of distributions we don't (yet?) support.
if [ "$OS" != 'Linux' ]; then
	echo >&2 "$0: Your OS ($OS) is currently not supported. Aborting."
	exit 1
fi

if [ -f /etc/mandrake-release ]; then
	unsupported_distro='Mandriva'
fi

if [ -f /etc/slackware-version ] || ([ -f /etc/os-release ] && . /etc/os-release && [ "$ID" = "slackware" ]); then
	echo >&2 "$0: Your distribution (Slackware) is currently not supported. Aborting. Try manually:"
	# lib edit requires a newer version than Slackware 14.2, for example Slackware-current
	echo >&2 "$0: # slackpkg install make gcc pkg-config libedit util-linux sqlite libxml2 patch wget"
	# required for libjansson
	echo >&2 "$0: # ./contrib/scripts/install_prereq install-unpackaged"
	exit 1
fi

if [ "$unsupported_distro" != '' ]; then
	echo >&2 "$0: Your distribution ($unsupported_distro) is currently not supported. Aborting."
	exit 1
fi

# The distributions we do support:
if [ -r /etc/debian_version ]; then
	handle_debian
else
	echo >&2 "$0: Only Debian is supported. Aborting."
	exit 1;
fi

echo;
echo "## $1 completed successfully"                      #;
echo "####################################################";
