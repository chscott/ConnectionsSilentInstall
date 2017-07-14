#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/iim/iim.conf

# Do initialization stuff
init ${iimStagingDir} uninstall

logUninstall 'Installation Manager' begin

# First see if IIM is even installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} -eq 1 ]; then
    log "I IIM does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# Uninstall IIM
if [ ${doUninstall} == "true" ]; then
    log "I Uninstalling IIM..."
    ${iimUninstall}
    checkStatus ${?} "E Failed to uninstall IIM. Exiting."
fi

# Clean up install artifacts
log "I Removing IIM installation directory..."
${rm} -f -r ${iimInstallDir}
log "I Removing IIM data directory..."
${rm} -f -r ${iimDataDir}
log "I Removing IIM shared data directory..."
${rm} -f -r ${iimSharedDataDir}

logUninstall 'Installation Manager' end
