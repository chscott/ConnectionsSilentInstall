#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables 
tdiUninstall="${tdiInstallDir}/_uninst/uninstaller"
tdiUninstallResponseFile="${stagingDir}/rsp/tdi_uninstall.rsp"
doUninstall="true"

log "I Beginning uninstall of TDI..."

# Do initialization stuff
init ${tdiStagingDir} uninstall

# Verify TDI is installed
result=$(isInstalled ${tdiInstallDir})
if [ ${result} -eq 1 ]; then
    log "I TDI does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# Uninstall TDI
if [ ${doUninstall} == "true" ]; then
    log "I Uninstalling TDI..."
    ${tdiUninstall} -f ${tdiUninstallResponseFile} -i silent
    checkStatus ${?} "I TDI uninstall failed. Exiting."
fi

# Remove install directory 
log "I Removing TDI installation directory ..."
${rm} -f -r ${tdiInstallDir}

# Print the results
log "I Success! TDI has been uninstalled."
