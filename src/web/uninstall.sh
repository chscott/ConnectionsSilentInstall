#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
webUninstallLog="${logDir}/web_uninstall.log"
listInstalledPackages="${iimInstallDir}/eclipse/tools/imcl listInstalledPackages"
uninstallPackages="${iimInstallDir}/eclipse/tools/imcl -log ${webUninstallLog} uninstall"
stopManager="${dmgrProfileDir}/bin/stopManager.sh"
doUninstall="true"

log "I Beginning uninstall of WebSphere components..."

# Do initialization stuff
init ${webStagingDir} uninstall

# See if WebSphere appears to be installed
log "I Checking to see if WebSphere is installed..."
result=$(isInstalled ${webInstallDir})
if [ ${result} -eq 1 ]; then
    log "I WebSphere does not appear to be installed. Skipping uninstall."
    doUninstall="false" 
fi

# See if IIM is installed
log "I Checking to see if IIM is installed..."
result=$(isInstalled ${iimInstallDir})
if [ ${result} -eq 1 ]; then
    log "I IIM does not appear to be installed. Skipping uninstall."
    doUninstall="false" 
fi

# Kill WebSphere processes
log "I Terminating IHS processes..."
${ps} -ef | ${grep} ${ihsInstallDir} | ${grep} -v 'grep' | ${awk} '{print $2}' | ${xargs} -r ${kill} -9
log "I Terminating WebSphere processes..."
${ps} -ef | ${grep} ${dmgrProfileDir} | ${grep} -v 'grep' | ${awk} '{print $2}' | ${xargs} -r ${kill} -9 >>${scriptLog} 2>&1
${ps} -ef | ${grep} ${ic1ProfileDir} | ${grep} -v 'grep' | ${awk} '{print $2}' | ${xargs} -r ${kill} -9

# Uninstall WebSphere packages
# TODO: do direct ID of WebSphere packages in case additional components are installed on the system 
if [ ${doUninstall} == "true" ]; then
    log "I Uninstalling WebSphere packages..."
    ${listInstalledPackages} | \
        ${grep} -v -E 'com.ibm.connections|com.ibm.cic.agent' | \
        ${xargs} -r -I package ${uninstallPackages} package >>${scriptLog} 2>&1
    checkStatus ${?} "E Failed to uninstall all WebSphere packages. Exiting." 
fi

# Remove install directory
log "I Removing WebSphere installation directory..."
${rm} -f -r ${webInstallDir}

# Remove data directory
log "I Removing WebSphere data directory..."
${rm} -f -r ${webDataDir}

# Print the results
log "I Success! WebSphere components have been uninstalled."
