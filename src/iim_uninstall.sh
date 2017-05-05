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
    log "INFO: IIM does not appear to be installed. Exiting."
    exit 0 
fi

# Uninstall IIM
log "INFO: Uninstalling IIM..."
${iimUninstall} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Failed to uninstall IIM. Exiting."

# Clean up install artifacts
log "INFO: Deleting ${iimInstallDir}..."
${rm} -f -r ${iimInstallDir}
log "INFO: Deleting ${iimDataDir}..."
${rm} -f -r ${iimDataDir}
log "INFO: Deleting ${iimSharedDataDir}..."
${rm} -f -r ${iimSharedDataDir}

# Print the results
log "INFO: Success! IIM has been uninstalled."
