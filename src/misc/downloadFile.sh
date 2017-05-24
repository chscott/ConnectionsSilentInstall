#!/bin/bash

# Local variables
ftpServer=${1}
ftpDir=${2}
file=${3}
curl="/usr/bin/curl --silent --fail --remote-name"

${curl} ftp://${ftpServer}/${ftpDir}/${file}
