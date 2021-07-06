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

for filename in "$ROOT_DIR"/packages/*.sh; do
  [ -e "$filename" ] || continue
  echo "Starting $filename";
  (
    ${SUDO_CMD} . "$filename";
  );
done