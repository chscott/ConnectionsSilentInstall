#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
iimUninstallLog="${logDir}/iim_uninstall.log"
iimUninstall="${iimDataDir}/uninstall/uninstallc -l ${iimUninstallLog}"
doUninstall="true"

log "I Beginning uninstall of IIM..."

# Do initialization stuff
init ${iimStagingDir} uninstall

# First see if IIM is even installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} -eq 1 ]; then
    log "I IIM does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# Uninstall IIM
if [ ${doUninstall} == "true" ]; then
    log "I Uninstalling IIM..."
    ${iimUninstall} >>${scriptLog} 2>&1
    checkStatus ${?} "E Failed to uninstall IIM. Exiting."
fi

# Clean up install artifacts
log "I Removing IIM installation directory..."
${rm} -f -r ${iimInstallDir}
log "I Removing IIM data directory..."
${rm} -f -r ${iimDataDir}
log "I Removing IIM shared data directory..."
${rm} -f -r ${iimSharedDataDir}

# Print the results
log "I Success! IIM has been uninstalled."
