#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
downloadFile="../src/misc/downloadFile.sh"
iimInstallLog="${logDir}/iim_install.log"
iimInstall="./installc -installationDirectory ${iimInstallDir} -dataLocation ${iimDataDir} -l ${iimInstallLog} -acceptLicense"
iimVersion="${iimInstallDir}/eclipse/tools/imcl version"

log "I Beginning installation of IIM..."

# Do initialization stuff
init ${iimStagingDir} install

# Download the install files 
log "I Downloading IIM installation files..."
{ ${downloadFile} ${ftpServer} ${ftpIIMDir} ${iimInstallPackage}; ${echo} ${?} >${childProcessTempDir}/${iimStagingDir}/${BASHPID}; } &

# Wait for file downloads to complete and then check status
wait
checkChildProcessStatus ${childProcessTempDir}/${iimStagingDir}

# Unpack the downloaded files
unpackFile zip "${iimInstallPackage}"

# Install IIM
log "I Installing IIM..."
${iimInstall} >>${scriptLog} 2>&1
checkStatus ${?} "E IIM installation failed. Exiting."

# Print the results
version=$(${iimVersion} | ${grep} "^Version" | ${cut} -d ' ' -f 2)
log "I Success! IIM ${version} has been installed."
