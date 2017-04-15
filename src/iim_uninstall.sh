#!/bin/bash

# Source prereq scripts
. src/utils.sh
. src/vars.sh

testForRoot

# Logs
iimUninstallLog="${stagingDir}/${iimStagingDir}/iim_uninstall.log"

# Commands
iimUninstall="${iimDataDir}/uninstall/uninstallc -l ${iimUninstallLog}"

# First see if IIM is even installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} == 1 ]; then
    log "IIM does not appear to be installed. Exiting."
    exit 1
fi

# Uninstall IIM
log "Uninstalling IBM Installation Manager..."
${iimUninstall} >/dev/null 2>&1
checkStatus ${?} "ERROR: IIM uninstall failed. Exiting."

# Print the results
log "SUCCESS! IBM Installation Manager has been uninstalled."
