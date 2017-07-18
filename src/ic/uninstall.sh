#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/ic/ic.conf

# Local variables
doUninstall='true'

# Do initialization stuff
init ic uninstall

logUninstall Connections begin

# See if Connections appears to be installed
log "I Checking to see if Connections is installed..."
result=$(isInstalled ${icInstallDir})
if [ ${result} -eq 1 ]; then
    log "I Connections does not appear to be installed. Skipping uninstall."
    doUninstall='false'
fi

# See if IIM is installed
log "I Checking to see if IIM is installed..."
result=$(isInstalled ${iimInstallDir})
if [ ${result} -eq 1 ]; then
    log "I IIM does not appear to be installed. Skipping uninstall."
    doUninstall='false'
fi

# Uninstall Connections 
if [ ${doUninstall} == 'true' ]; then
    log "I Uninstalling Connections..."
    ${imcl} listInstalledPackages | \
        ${grep} 'connections' | \
        ${xargs} -I package ${imcl} -log ${icUninstallLog} uninstall package
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

# Remove the JDBC directory
log "I Removing JDBC directory..."
${rm} -f -r ${jdbcDir}

logUninstall Connections end
