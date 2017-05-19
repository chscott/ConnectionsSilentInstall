#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
wasUninstallLog="${logDir}/was_uninstall.log"
listInstalledPackages="${iimInstallDir}/eclipse/tools/imcl listInstalledPackages"
uninstallPackages="${iimInstallDir}/eclipse/tools/imcl -log ${wasUninstallLog} uninstall"
stopManager="${dmgrProfileDir}/bin/stopManager.sh"
doUninstall="true"

# Do initialization stuff
init ${wasStagingDir} uninstall

# Kill WebSphere processes
log "INFO: Terminating IHS processes..."
${ps} -ef | ${grep} ${ihsInstallDir} | ${grep} -v 'grep' | ${awk} '{print $2}' | ${xargs} -r ${kill} -9
log "INFO: Terminating WAS processes..."
${ps} -ef | ${grep} ${dmgrProfileDir} | ${grep} -v 'grep' | ${awk} '{print $2}' | ${xargs} -r ${kill} -9 >>${scriptLog} 2>&1
${ps} -ef | ${grep} ${icProfileDir} | ${grep} -v 'grep' | ${awk} '{print $2}' | ${xargs} -r ${kill} -9

# Remove WAS data directory
log "INFO: Removing WAS data directory..."
${rm} -f -r ${wasDataDir}

# See if WAS appears to be installed
log "INFO: Checking to see if WAS is installed..."
result=$(isInstalled ${wasInstallDir})
if [ ${result} -eq 1 ]; then
    log "INFO: WAS does not appear to be installed. Skipping uninstall."
    doUninstall="false" 
fi

# See if IIM is installed
log "INFO: Checking to see if IIM is installed..."
result=$(isInstalled ${iimInstallDir})
if [ ${result} -eq 1 ]; then
    log "INFO: IIM does not appear to be installed. Skipping uninstall."
    doUninstall="false" 
fi

# Uninstall WebSphere packages
# TODO: do direct ID of WebSphere packages in case additional components are installed on the system 
if [ ${doUninstall} == "true" ]; then
    log "INFO: Uninstalling WebSphere packages..."
    ${listInstalledPackages} | \
        ${grep} -v -E 'com.ibm.connections|com.ibm.cic.agent' | \
        ${xargs} -r -I package ${uninstallPackages} package >>${scriptLog} 2>&1
    checkStatus ${?} "ERROR: Failed to uninstall all WebSphere packages. Exiting." 
fi

# Remove install directory
log "INFO: Removing WebSphere installation directory..."
${rm} -f -r ${websphereInstallDir}

# Remove data directory
log "INFO: Removing WebSphere data directory..."
${rm} -f -r ${websphereDataDir}

# Print the results
log "INFO: Success! WebSphere has been uninstalled."
