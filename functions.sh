#!/usr/bin/sh


installPhpExtension()
{
	local extensionName="$1";
	local extensionUrl="$2";
	local extensionPriority="$3";
	local extensionPrefix="$4";
	local extensionConfOpt="$5";
	
	${SUDO_CMD} curl -LO "$extensionUrl";
	local arhiveName=$(basename "$extensionUrl");
	local dirName=$(tar -tf "${PWD}/${arhiveName}" | cut -f 1 -d '/' | sort -u | grep -v package.xml);
	${SUDO_CMD} tar xzf "${PWD}/${arhiveName}"
	makePhpExtension "${PWD}/${dirName}" "$extensionConfOpt"
	enablePhpExtension "$extensionName" "$extensionPriority" "$extensionPrefix" 
	${SUDO_CMD} rm -rf "${PWD}/${arhiveName}" "${PWD}/${dirName}"
	
}

enablePhpExtension()
{
	local libFileName="$1";
	local priotity="$2";
	local prefix="$3";
	
	${SUDO_CMD} echo "${prefix}extension=${libFileName}.so" > /tmp/${libFileName}.ini;
	
	${SUDO_CMD} rm -rf /etc/php/$PHP_VERSION/mods-available/${libFileName}.ini /etc/php/$PHP_VERSION/fpm/conf.d/${priotity}-${libFileName}.ini /etc/php/$PHP_VERSION/cli/conf.d/${priotity}-${libFileName}.ini;
	${SUDO_CMD} mv /tmp/${libFileName}.ini /etc/php/$PHP_VERSION/mods-available/${libFileName}.ini; 
	${SUDO_CMD} ln -s /etc/php/$PHP_VERSION/mods-available/${libFileName}.ini /etc/php/$PHP_VERSION/fpm/conf.d/${priotity}-${libFileName}.ini;
	${SUDO_CMD} ln -s /etc/php/$PHP_VERSION/mods-available/${libFileName}.ini /etc/php/$PHP_VERSION/cli/conf.d/${priotity}-${libFileName}.ini;

}

makePhpExtension()
{
	local dirName="$1";
	local confOptions="$2"
	
	cd ${dirName}
	${SUDO_CMD} phpize >> $LOG_FILE 2>> $LOG_FILE;
	${SUDO_CMD} ./configure "$confOptions" >> $LOG_FILE 2>> $LOG_FILE;
	${SUDO_CMD} make >> $LOG_FILE 2>> $LOG_FILE;
	${SUDO_CMD} make install >> $LOG_FILE 2>> $LOG_FILE;
	cd ..
}