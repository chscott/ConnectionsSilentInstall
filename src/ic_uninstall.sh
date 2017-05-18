#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
icUninstallLog="${logDir}/ic_uninstall.log"
listInstalledPackages="${iimInstallDir}/eclipse/tools/imcl listInstalledPackages"
uninstallPackages="${iimInstallDir}/eclipse/tools/imcl -log ${icUninstallLog} uninstall"
doUninstall="true"

# Do initialization stuff
init ic uninstall

# See if Connections appears to be installed
log "INFO: Checking to see if Connections is installed..."
result=$(isInstalled ${icInstallDir})
if [ ${result} -eq 1 ]; then
    log "INFO: Connections does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# See if IIM is installed
log "INFO: Checking to see if IIM is installed..."
result=$(isInstalled ${iimInstallDir})
if [ ${result} -eq 1 ]; then
    log "INFO: IIM does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# Uninstall Connections 
if [ ${doUninstall} == "true" ]; then
    log "INFO: Uninstalling Connections..."
    ${listInstalledPackages} | ${grep} 'connections' | ${xargs} -I package ${uninstallPackages} package >>${scriptLog} 2>&1
    checkStatus ${?} "ERROR: Failed to uninstall Connections. Exiting." 
fi

# Remove install directory
log "INFO: Removing Connections installation directory..."
${rm} -f -r ${icInstallDir}

# Remove data directory
log "INFO: Removing Connections data directory..."
${rm} -f -r ${icDataDir}

# Print the results
log "INFO: Success! Connections has been uninstalled."
