#!/bin/bash

# Local variables
ftpServer=${1}
ftpDir=${2}
files=${3}
wget="/usr/bin/wget --quiet"

${wget} ftp://${ftpServer}/${ftpDir}/${files}
