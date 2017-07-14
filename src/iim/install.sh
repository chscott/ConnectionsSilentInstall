#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/iim/iim.conf

# Do initialization stuff
init ${iimStagingDir} install

logInstall 'Installation Manager' begin

# Download and unpack the install files 
log "I Downloading IIM install files..."
{ ${downloadFile} ${ftpServer} ${ftpIIMDir} ${iimInstallPackage}; ${echo} ${?} >${childProcessTempDir}/${iimStagingDir}/${BASHPID}; } &
wait
checkChildProcessStatus ${childProcessTempDir}/${iimStagingDir}
unpackFile zip "${iimInstallPackage}"

# Install IIM
log "I Performing IIM install..."
${iimInstall}
checkStatus ${?} "E IIM installation failed. Exiting."

logInstall 'Installation Manager' end
