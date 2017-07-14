#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/tdi/tdi.conf

# Do initialization stuff
init ${tdiStagingDir} uninstall

logUninstall TDI begin

# Verify TDI is installed
result=$(isInstalled ${tdiInstallDir})
if [ ${result} -eq 1 ]; then
    log "I TDI does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# Kill TDI processes
log "I Terminating TDI processes..."
${ps} -ef | ${grep} ${tdiInstallDir} | ${grep} -v 'grep' | ${awk} '{print $2}' | ${xargs} -r ${kill} -9

# Uninstall TDI
if [ ${doUninstall} == "true" ]; then
    log "I Uninstalling TDI..."
    ${tdiUninstall} -f ${tdiUninstallResponseFile} -i silent
    checkStatus ${?} "I TDI uninstall failed. Exiting."
fi

# Remove install directory 
log "I Removing TDI installation directory ..."
${rm} -f -r ${tdiInstallDir}

logUninstall TDI end
