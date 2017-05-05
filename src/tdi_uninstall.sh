#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables 
tdiUninstall="${tdiInstallDir}/_uninst/uninstaller"
tdiUninstallResponseFile="${stagingDir}/responsefiles/tdi_uninstall.rsp"

# Do initialization stuff
init tdi uninstall

# Verify TDI is installed
result=$(isInstalled ${tdiInstallDir})
if [ ${result} -eq 1 ]; then
    log "INFO: TDI does not appear to be installed. Exiting."
    exit 0
fi

# Uninstall TDI
log "INFO: Uninstalling TDI..."
${tdiUninstall} -f ${tdiUninstallResponseFile} -i silent
checkStatus ${?} "ERROR: TDI uninstall failed. Exiting."

# Clean up install artifacts
log "INFO: Deleting ${tdiInstallDir}..."
${rm} -f -r ${tdiInstallDir}

# Print the results
log "INFO: Success! TDI has been uninstalled."
