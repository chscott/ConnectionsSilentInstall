#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/web/web.conf

# Do initialization stuff
init ${webStagingDir} update 

logUninstall 'WAS Java SDK Update' begin

# First see if IIM is installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} == 1 ]; then
    log "E IIM does not appear to be installed. Exiting."
    exit 1
fi

# Ensure the deployment manager is started
stopWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E Unable to stop deployment manager. Exiting."

# Ensure the Connections application server is stopped
stopWASServer ${ic1ServerName} ${ic1ProfileDir}
checkStatus ${?} "E Unable to stop Connections application server. Exiting."

# Ensure the Connections application server node agent is stopped
stopWASServer nodeagent ${ic1ProfileDir}
checkStatus ${?} "E Unable to stop Connections node agent. Exiting."

# Get the next-to-last SDK installed (should be the prior SDK)
revertSDK=$(${manageSDK} -listAvailable | ${grep} "SDK name:" | ${awk} '{print $4}' | ${sort} -n | ${tail} -2 | ${head} -1)

# Update the JVM for the deployment manager profile
log "I Enabling SDK ${revertSDK} for the deployment manager profile..."
${manageSDK} -enableProfile -profileName ${dmgrProfileName} -sdkname ${revertSDK} -user ${dmgrAdminUser} -password ${defaultPwd}
checkStatus ${?} "E Unable to update the Java SDK on the deployment manager. Exiting."

# Start the deployment manager
startWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E Unable to start deployment manager. Exiting."

# Update the JVM for the application server profile
log "I Enabling SDK ${revertSDK} for the application server profile..."
${manageSDK} -enableProfile -profileName ${ic1ProfileName} -sdkname ${revertSDK} -user ${dmgrAdminUser} -password ${defaultPwd}
checkStatus ${?} "E Unable to update the Java SDK on the Connections application server. Exiting."

# Update the default JVM for commands
${manageSDK} -setCommandDefault -sdkname ${revertSDK}
checkStatus ${?} "E Unable to update the default Java SDK for commands. Exiting."

# Run a node agent sync
syncWASNode
checkStatus ${?} "E Unable to synchronize the node. Exiting."

# Uninstall the package
log "I Uninstalling WebSphere Java SDK package..."
${imcl} listInstalledPackages | \
    ${grep} 'IBMJAVA' | \
    ${xargs} -I package ${imcl} -log ${javaUninstallLog} uninstall package
checkStatus ${?} "E Uninstall of WebSphere Java SDK failed."

logUninstall 'WAS Java SDK Update' end 
