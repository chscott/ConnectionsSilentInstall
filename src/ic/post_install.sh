#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables 
propagatePluginKeystore="${stagingDir}/src/web/propagate_keys.sh"
configureCCM="${stagingDir}/src/ic/config_ccm.sh"
updateJavaSDK="${stagingDir}/src/web/upgrade_java.sh"

log "I Beginning Connections post-install tasks..."

# Do initialization stuff
init ${icStagingDir} configure 

# Propagate the plug-in keystore 
${propagatePluginKeystore}
checkStatus ${?} "E Unable to propagate plug-in keystore. Exiting."

# Restart the web server to load the updated plug-in
result=$(restartIHSServer)
if [ ${result} -ne 0 ]; then
    log "W Manual IHS restart required. Continuing..."
fi

# Do a full restart/resync of WAS servers
restartAllWASServersWithNodeSync
checkStatus ${?} "E Unable to restart all WAS servers. Exiting."

# Configure CCM (don't swallow output since user will be prompted for info)
log "I Configuring CCM..."
${configureCCM}
checkStatus ${?} "E Unable to configure CCM. Exiting."

# Update the WAS Java SDK
log "I Updating Java SDK for WebSphere Application Server..."
${updateJavaSDK}
checkStatus ${?} "E Unable to update Java SDK for WebSphere Application Server. Exiting."

log "I Success! Connections post-install tasks completed."
