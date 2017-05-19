#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
iimUninstallLog="${logDir}/iim_uninstall.log"
iimUninstall="${iimDataDir}/uninstall/uninstallc -l ${iimUninstallLog}"
doUninstall="true"

log "UNINSTALL: Beginning uninstall of IIM..."

# Do initialization stuff
init ${iimStagingDir} uninstall

# First see if IIM is even installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} -eq 1 ]; then
    log "INFO: IIM does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# Uninstall IIM
if [ ${doUninstall} == "true" ]; then
    log "INFO: Uninstalling IIM..."
    ${iimUninstall} >>${scriptLog} 2>&1
    checkStatus ${?} "ERROR: Failed to uninstall IIM. Exiting."
fi

# Clean up install artifacts
log "INFO: Removing IIM installation directory..."
${rm} -f -r ${iimInstallDir}
log "INFO: Removing IIM data directory..."
${rm} -f -r ${iimDataDir}
log "INFO: Removing IIM shared data directory..."
${rm} -f -r ${iimSharedDataDir}

# Print the results
log "UNINSTALL: Success! IIM has been uninstalled."
