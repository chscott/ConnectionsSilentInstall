#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
iimUninstallLog="${logDir}/iim_uninstall.log"
iimUninstall="${iimDataDir}/uninstall/uninstallc -l ${iimUninstallLog}"

# Do initialization stuff
init iim uninstall

# First see if IIM is even installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} -eq 1 ]; then
    log "ERROR: IIM does not appear to be installed. Exiting."
    exit 1
fi

# Uninstall IIM
log "Uninstalling IIM..."
${iimUninstall} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Failed to uninstall IIM. Exiting."

# Clean up install artifacts
log "Deleting ${iimInstallDir}..."
${rm} -f -r ${iimInstallDir}
log "Deleting ${iimDataDir}..."
${rm} -f -r ${iimDataDir}
log "Deleting ${iimSharedDataDir}..."
${rm} -f -r ${iimSharedDataDir}

# Print the results
log "SUCCESS! IIM has been uninstalled."
