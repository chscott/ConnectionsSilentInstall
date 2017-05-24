#!/bin/bash

. ../src/misc/commands.sh
. ../src/misc/vars.sh
. ../src/misc/utils.sh

dir=${1}
file=${2}

log "I Downloading ${file} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${dir}/${file} >/dev/null 2>&1
checkStatus ${?} "E Download failed. Exiting."
