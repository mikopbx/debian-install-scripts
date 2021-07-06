#!/bin/bash
(
# Добавляем модуль 8021q в автозагрузку. Поддержка VLAN.
module_8021q=$(grep 8021q </etc/modules);
${SUDO_CMD} cat /etc/modules > /tmp/modules_miko;
if [ 'x' = "x${module_8021q}" ]; then
	${SUDO_CMD} echo 8021q >> /tmp/modules_miko;
	${SUDO_CMD} mv /tmp/modules_miko /etc/modules;
fi;
)
