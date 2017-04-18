#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Logs
iimUninstallLog="${stagingDir}/${iimStagingDir}/iim_uninstall.log"

# Commands
iimUninstall="${iimDataDir}/uninstall/uninstallc -l ${iimUninstallLog}"

# Make sure script is running as root
checkForRoot

# First see if IIM is even installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} == 1 ]; then
    log "WARNING: IIM does not appear to be installed. Exiting."
    exit 1
fi

# Uninstall IIM
log "Uninstalling IBM Installation Manager..."
${iimUninstall} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: IIM uninstall failed. Exiting."

# Print the results
log "SUCCESS! IBM Installation Manager has been uninstalled."
