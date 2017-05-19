#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables 
tdiUninstall="${tdiInstallDir}/_uninst/uninstaller"
tdiUninstallResponseFile="${stagingDir}/rsp/tdi_uninstall.rsp"
doUninstall="true"

log "UNINSTALL: Beginning uninstall of TDI..."

# Do initialization stuff
init ${tdiStagingDir} uninstall

# Verify TDI is installed
result=$(isInstalled ${tdiInstallDir})
if [ ${result} -eq 1 ]; then
    log "INFO: TDI does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# Uninstall TDI
if [ ${doUninstall} == "true" ]; then
    log "INFO: Uninstalling TDI..."
    ${tdiUninstall} -f ${tdiUninstallResponseFile} -i silent
    checkStatus ${?} "ERROR: TDI uninstall failed. Exiting."
fi

# Remove install directory 
log "INFO: Removing TDI installation directory ..."
${rm} -f -r ${tdiInstallDir}

# Print the results
log "UNINSTALL: Success! TDI has been uninstalled."
