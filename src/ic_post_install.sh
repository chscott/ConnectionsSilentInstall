#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables 
propagatePluginKeystore="${stagingDir}/src/was_propagate_keystore.sh"
syncNode="${icProfileDir}/bin/syncNode.sh ${fqdn} -username ${dmgrAdminUser} -password ${defaultPwd}"

log "INSTALL: Beginning Connections post-install tasks..."

# Do initialization stuff
init ${icStagingDir} configure 

# Propagate the plug-in keystore 
${propagatePluginKeystore}
checkStatus ${?} "ERROR: Unable to propagate plug-in keystore. Exiting."

# Restart the web server to load the updated plug-in
result=$(restartIHSServer)
if [ ${result} -ne 0 ]; then
    log "WARNING: Manual IHS restart required. Continuing..."
fi

# Make sure the Connections application server is stopped
result=$(stopWASServer ${icServerName} ${icProfileDir})
checkStatus ${result} "ERROR: Unable to stop the Connections application server. Exiting."

# Make sure the node agent is stopped 
result=$(stopWASServer nodeagent ${icProfileDir})
checkStatus ${result} "ERROR: Unable to stop node agent. Exiting."

# Make sure the deployment manager is running
result=$(startWASServer ${dmgrServerName} ${dmgrProfileDir})
checkStatus ${result} "ERROR: Unable to start the deployment manager. Exiting"

# Run a node agent sync
log "Synchronizing node..."
${syncNode} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to synchronize the node. Exiting."

# Restart the deployment manager
result=$(restartWASServer ${dmgrServerName} ${dmgrProfileDir})
checkStatus ${result} "ERROR: Unable to restart the deployment manager. Exiting."

# Start the node agent
result=$(startWASServer nodeagent ${icProfileDir})
checkStatus ${result} "ERROR: Unable to start node agent. Exiting."

# Restart the Connections application server
result=$(restartWASServer ${icServerName} ${icProfileDir})
checkStatus ${result} "ERROR: Unable to restart the Connections application server. Exiting."

log "INSTALL: Success! Connections post-install tasks completed."
