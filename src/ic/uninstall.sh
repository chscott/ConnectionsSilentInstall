#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
icUninstallLog="${logDir}/ic_uninstall.log"
listInstalledPackages="${iimInstallDir}/eclipse/tools/imcl listInstalledPackages"
uninstallPackages="${iimInstallDir}/eclipse/tools/imcl -log ${icUninstallLog} uninstall"
doUninstall="true"
revertSDK="${stagingDir}/src/web/revert_java.sh"

log "I Beginning uninstall of Connections"

# Do initialization stuff
init ${icStagingDir} uninstall

# See if Connections appears to be installed
log "I Checking to see if Connections is installed..."
result=$(isInstalled ${icInstallDir})
if [ ${result} -eq 1 ]; then
    log "I Connections does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# See if IIM is installed
log "I Checking to see if IIM is installed..."
result=$(isInstalled ${iimInstallDir})
if [ ${result} -eq 1 ]; then
    log "I IIM does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# Uninstall Connections 
if [ ${doUninstall} == "true" ]; then
    log "I Uninstalling Connections..."
    ${listInstalledPackages} | ${grep} 'connections' | ${xargs} -I package ${uninstallPackages} package >>${scriptLog} 2>&1
    checkStatus ${?} "E Failed to uninstall Connections. Exiting." 
fi

# Uninstall Java SDK update
log "I Reverting Java SDK..."
${revertSDK}

# Remove install directory
log "I Removing Connections installation directory..."
${rm} -f -r ${icInstallDir}

# Remove data directory
log "I Removing Connections data directory..."
${rm} -f -r ${icDataDir}

# Print the results
log "I Success! Connections has been uninstalled."
