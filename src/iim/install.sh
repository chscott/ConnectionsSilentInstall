#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/iim/iim.conf

# Do initialization stuff
init iim install

logInstall 'Installation Manager' begin

# Download and unpack the install files 
log "I Downloading IIM install files..."
{ ${downloadFile} ${ftpServer} ${ftpIIMDir} ${iimInstallPackage}; ${echo} ${?} >${childProcessTempDir}/iim/${BASHPID}; } &
wait
checkChildProcessStatus ${childProcessTempDir}/iim
unpackFile zip "${iimInstallPackage}"

# Install IIM
log "I Performing IIM install..."
${iimInstall}
checkStatus ${?} "E IIM installation failed. Exiting."

logInstall 'Installation Manager' end
