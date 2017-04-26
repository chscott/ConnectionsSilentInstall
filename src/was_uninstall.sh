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

# Terminate all WAS processes. This is a best effort, as there's no guarantee the process
# is even running when the uninstall is performed.
log "Checking to see if there are any WAS profiles..."
result=$(isInstalled ${wasDataDir})
if [ ${result} -eq 0 ]; then
    # DMGR
    log "Terminating Deployment Manager..."
    dmgrPid=$(${cat} ${dmgrProfilePath}/logs/dmgr/dmgr.pid 2>/dev/null)
    ${kill} -9 ${dmgrPid} >>${scriptLog} 2>&1
    # Other WAS processes here
    # Remove WAS data directory
    log "Removing WAS data directory..."
    ${rm} -f -r ${wasDataDir}
else
    log "No WAS profiles found. Continuing..."
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

# Remove data directory
log "Removing WebSphere data directory..."
${rm} -f -r ${websphereDataDir}

# Print the results
log "SUCCESS! WebSphere has been uninstalled."
