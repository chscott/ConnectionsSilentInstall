#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
iimInstallLog="${logDir}/iim_install.log"
iimInstall="./installc -installationDirectory ${iimInstallDir} -dataLocation ${iimDataDir} -l ${iimInstallLog} -acceptLicense"
iimVersion="${iimInstallDir}/eclipse/tools/imcl version"

# Do initialization stuff
init iim install

# Download the install file
downloadFile iim "${iimInstallPackage}"

# Unpack the downloaded files
unpackFile zip "${iimInstallPackage}"

# Install IIM
log "INFO: Installing IIM..."
${iimInstall} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: IIM installation failed. Exiting."

# Print the results
version=$(${iimVersion} | ${grep} "^Version" | ${cut} -d ' ' -f 2)
log "INFO: Success! IBM Installation Manager ${version} has been installed."
