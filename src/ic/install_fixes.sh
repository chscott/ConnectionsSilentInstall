#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/ic/ic.conf

# Do initialization stuff
init ic update 

logInstall 'Connections Fixes' begin

# Make sure the WAS servers are started
startWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E Unable to start deployment manager. Exiting."
startWASServer nodeagent ${ic1ProfileDir}
checkStatus ${?} "E Unable to start node agent. Exiting."
startWASServer ${ic1ServerName} ${ic1ProfileDir}
checkStatus ${?} "E Unable to application server. Exiting."

# Set WAS_HOME variable
. ${exportVarsScript}
checkStatus ${?} "E Failure encountered when running ${exportVarsScript}. Exiting."

# Download the fixes 
log "I Downloading Connections fixes..."
{ ${downloadFiles} ${ftpServer} ${ftpConnectionsDir} ${fixFiles}; ${echo} ${?} >${childProcessTempDir}/ic/${BASHPID}; } &
wait
checkChildProcessStatus ${childProcessTempDir}/ic
resetChildProcessTempDir ${childProcessTempDir}/ic

# Create the fix directory if it doesn't already exist
${mkdir} -p ${fixDir}

# Move the files to the fix directory
${mv} ${fixFiles} ${fixDir}

# Have to change to the updateSilent.sh directory or WAS_HOME will be reset to a bogus directory
cd ${icInstallDir}/updateInstaller

# Ensure root has execute permission on the updateSilent script
${chmod} u+x ${updateSilent}
checkStatus ${?} "E Failed to update permissions on ${updateSilent}. Exiting."

# See which fixes have already been installed
existingFixes=$(${updateSilent} -fix -installDir ${icInstallDir} | \
                ${grep} 'Fix name:' | \
                ${awk} -F ': ' '{print $2}' | \
                ${sort} | \
                ${sed} 'N;s|\n| |') 
checkStatus ${?} "E Failed to get the list of existing installed fixes. Exiting."
log "I Installed fixes: ${existingFixes}"

# See which fixes are available to install
availableFixes=$(${updateSilent} -fix -installDir ${icInstallDir} -fixDir ${fixDir} | \
                 ${grep} -E '^\[[0-9]\]' | \
                 ${awk} '{print $2}' | \
                 ${sort} | \
                 ${sed} 'N;s|\n| |' | \
                 ${tr} -d ',') 
checkStatus ${?} "E Failed to get the list of fixes available to install. Exiting."
log "I Available fixes: ${availableFixes}"

# Filter out the fixes that are both available and already installed. The remainder are the ones we need to install
installFixes=""
for availableFix in ${availableFixes}; do
    alreadyInstalled="false"
    for existingFix in ${existingFixes}; do
        if [ ${existingFix} == ${availableFix} ]; then
            alreadyInstalled="true" 
        fi
    done
    if [ ${alreadyInstalled} == "false" ]; then
        installFixes="${availableFix} ${installFixes}" 
    fi
done

# Invoke updateSilent to apply the fixes
if [ ! -z "${installFixes}" ]; then
    log "I Installing the following fixes: ${installFixes}..."
    ${updateSilent} -fix -installDir ${icInstallDir} -fixDir ${fixDir} -install -fixes ${installFixes} \
                    -wasUserId ${dmgrAdminUser} -wasPassword ${defaultPwd} -featureCustomizationBackedUp yes
    checkStatus ${?} "E Failed to install Connections fixes. Exiting."
else
    log "I There are no available fixes to install. Skipping."
    exit 0 
fi

# Do a full restart with resync
restartAllWASServersWithNodeSync
checkStatus ${?} "E Unable to restart all WAS servers. Exiting."

logInstall 'Connections Fixes' end
