#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Logs
wasUninstallLog="${stagingDir}/${wasStagingDir}/was_uninstall.log"

# Commands
listInstalledPackages="${iimInstallDir}/eclipse/tools/imcl listInstalledPackages"
uninstallPackages="${iimInstallDir}/eclipse/tools/imcl -log ${wasUninstallLog} uninstall"

# Make sure script is running as root
checkForRoot

# First see if IIM is even installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} == 1 ]; then
    log "WARNING: IIM does not appear to be installed. Exiting."
    exit 1
fi

# Uninstall any installed packages (except IIM)
log "Uninstalling WebSphere packages..."
${listInstalledPackages} | ${grep} -v 'com.ibm.cic.agent' | ${xargs} -I package ${uninstallPackages} package >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Failed to uninstall all WebSphere packages. Review ${wasUninstallLog} for details." 

# Remove install directory
log "Removing WebSphere installation directory..."
${rm} -f -r ${websphereInstallDir}
checkStatus ${?} "ERROR: Failed to remove ${websphereInstallDir}. Manual cleanup required."

# Print the results
log "SUCCESS! All WebSphere packages were uninstalled."
