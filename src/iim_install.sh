#!/bin/bash

# Source prereq scripts
. src/utils.sh
. src/vars.sh

testForRoot

# Logs
iimInstallLog="${stagingDir}/${iimStagingDir}/iim_install.log"

# Commands
iimInstall="./installc -installationDirectory ${iimInstallDir} -dataLocation ${iimDataDir} -l ${iimInstallLog} -acceptLicense"
iimVersion="${iimInstallDir}/eclipse/tools/imcl version"

iimInstallPackage="agent.installer.linux.gtk.x86_64_1.8.5001.20161016_1705.zip"

# Clean up from prior run of install script
${rm} -f -r ${stagingDir}/${iimStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unable to remove ${stagingDir}/${iimStagingDir}. Exiting."
${mkdir} ${stagingDir}/${iimStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unable to create ${stagingDir}/${iimStagingDir}. Exiting."
cd ${stagingDir}/${iimStagingDir}

# Download the IIM installation file
log "Downloading ${iimInstallPackage} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${iimStagingDir}/${iimInstallPackage} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."

# Unpack the downloaded files
log "Unpacking ${iimInstallPackage}..."
${unzip} -qq ${iimInstallPackage} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."

# Install IIM
log "Installing ${iimInstallPackage}..."
${iimInstall} >/dev/null 2>&1
checkStatus ${?} "ERROR: IIM installation failed. Exiting."

# Print the results
log "SUCCESS! IBM Installation Manager has been installed. Printing version info...\n"
${iimVersion}
log "\n"
