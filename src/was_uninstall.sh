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
stopManager="${dmgrProfilePath}/bin/stopManager.sh"

# Make sure script is running as root
checkForRoot

# Stop all WAS processes
log "Checking to see if there are any WAS profiles..."
result=$(isInstalled ${wasDataDir})
if [ ${result} -eq 0 ]; then
    log "Stopping Deployment Manager..."
    ${stopManager} "-user" "${dmgrAdminUser}" "-password" "${defaultPwd}" >>${scriptLog} 2>&1
    checkStatus ${?} "ERROR: Failed to stop Deployment Manager process. Exiting."
    # Remove data directory
    log "Removing WebSphere data directory..."
    ${rm} -f -r ${websphereDataDir}
    checkStatus ${?} "ERROR: Failed to remove ${websphereDataDir}. Manual cleanup required."
fi

# See if WAS appears to be installed
log "Checking to see if WAS is installed..."
result=$(isInstalled ${wasInstallDir})
if [ ${result} -eq 1 ]; then
    log "WARNING: WAS does not appear to be installed. Exiting."
    exit 1
fi

# See if IIM is installed
log "Checking to see if IIM is installed..."
result=$(isInstalled ${iimInstallDir})
if [ ${result} -eq 1 ]; then
    log "WARNING: IIM does not appear to be installed. Exiting."
    exit 1
fi

# Uninstall any installed packages (except IIM)
log "Uninstalling WebSphere packages..."
${listInstalledPackages} | ${grep} -v 'com.ibm.cic.agent' | ${xargs} -I package ${uninstallPackages} package >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Failed to uninstall all WebSphere packages. Review ${wasUninstallLog} and ${scriptLog} for details." 

# Remove install directory
log "Removing WebSphere installation directory..."
${rm} -f -r ${websphereInstallDir}
checkStatus ${?} "ERROR: Failed to remove ${websphereInstallDir}. Manual cleanup required."

# Print the results
log "SUCCESS! All WebSphere packages were uninstalled."
