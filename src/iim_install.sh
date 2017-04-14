#!/bin/bash

# Source prereq scripts
. src/utils.sh
. src/vars.sh

# Directories
iimStagingDir="iim"
iimInstallDir="/opt/ibm/iim"

# Logs
iimInstallLog="${stagingDir}/${iimStagingDir}/"

# Commands

# Status codes

# FTP
ftpServer="cs-ftp.swg.usma.ibm.com"
iimInstallPackage="agent.installer.linux.gtk.x86_64_1.8.5001.20161016_1705.zip"

# Users and groups

testForRoot

# Clean up from prior run of install script
${rm} -f -r ${stagingDir}/${iimStagingDir}
checkStatus ${?} "ERROR: Unable to remove ${stagingDir}/${iimStagingDir}. Exiting."
${mkdir} ${stagingDir}/${iimStagingDir}
checkStatus ${?} "ERROR: Unable to create ${stagingDir}/${iimStagingDir}. Exiting."
cd ${stagingDir}/${iimStagingDir}

# Download the IIM installation file
log "Downloading ${iimInstallPackage} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${iimStagingDir}/${iimInstallPackage}
checkStatus ${?} "ERROR: Download failed. Exiting."

# Unpack the downloaded files
log "Unpacking ${iimInstallPackage}..."
${tar} -zxf ${iimInstallPackage} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
