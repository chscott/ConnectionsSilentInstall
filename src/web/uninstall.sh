#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/web/web.conf

# Do initialization stuff
init web uninstall

logUninstall 'WebSphere Components' begin

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
${ps} -ef | ${grep} ${dmgrProfileDir} | ${grep} -v 'grep' | ${awk} '{print $2}' | ${xargs} -r ${kill} -9
${ps} -ef | ${grep} ${ic1ProfileDir} | ${grep} -v 'grep' | ${awk} '{print $2}' | ${xargs} -r ${kill} -9

# Uninstall WebSphere packages
# TODO: do direct ID of WebSphere packages in case additional components are installed on the system 
if [ ${doUninstall} == "true" ]; then
    log "I Uninstalling WebSphere packages..."
    ${imcl} listInstalledPackages | \
        ${grep} -v -E 'com.ibm.connections|com.ibm.cic.agent' | \
        ${xargs} -r -I package ${imcl} -log ${webUninstallLog} uninstall package
    checkStatus ${?} "E Failed to uninstall all WebSphere packages. Exiting." 
fi

# Remove install directory
log "I Removing WebSphere installation directory..."
${rm} -f -r ${webInstallDir}

# Remove data directory
log "I Removing WebSphere data directory..."
${rm} -f -r ${webDataDir}

# Remove WebSphere temp directory
log "I Removing WebSphere temp directory..."
${rm} -f -r ${webTempDir}

logUninstall 'WebSphere Components' end
