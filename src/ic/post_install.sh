#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/ic/ic.conf

# Do initialization stuff
init ${icStagingDir} configure 

logConfigure 'Connections Post-install Tasks' begin

# Propagate the plug-in keystore 
${propagatePluginKeystore}
checkStatus ${?} "E Unable to propagate plug-in keystore. Exiting."

# Do a full restart/resync of WAS servers
restartAllWASServersWithNodeSync
checkStatus ${?} "E Unable to restart all WAS servers. Exiting."

# Configure CCM (don't swallow output since user will be prompted for info)
if [ ${installIcCCM} == 'true' ]; then
    log "I Configuring CCM..."
    ${configureCCM}
    checkStatus ${?} "E Unable to configure CCM. Exiting."
fi

# Update the WAS Java SDK
log "I Updating Java SDK for WebSphere Application Server..."
${updateJavaSDK}
checkStatus ${?} "E Unable to update Java SDK for WebSphere Application Server. Exiting."

# Install Connections fixes
log "I Installing Connections fixes..."
${installICFixes} 
checkStatus ${?} "E Unable to install Connections fixes. Exiting."

logConfigure 'Connections Post-install Tasks' end 
