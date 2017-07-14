#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/web/web.conf

# Do initialization stuff
init ${webStagingDir} update 

logInstall 'WebSphere Java SDK Update' begin

# First see if IIM is installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} == 1 ]; then
    log "E IIM does not appear to be installed. Exiting."
    exit 1
fi

# Download the install files 
log "I Downloading WebSphere Java SDK install file..."
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webJavaSDKPackage}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &

# Wait for file downloads to complete and then check status
wait
checkChildProcessStatus ${childProcessTempDir}/${webStagingDir}

# Unpack the downloaded files
unpackFileToDirectory zip "${webJavaSDKPackage}" "${webJavaSDKStagingDir}"

# Extract the component ID and version info
log "I Extracting package IDs and version information from repositories..."
sdkIdVersion=$(${imcl} listAvailablePackages -repositories "${webJavaSDKPackage}" | ${grep} -F 'com.ibm.websphere.IBMJAVA' | ${sort} | ${tail} -1)

# Stop the servers 
stopWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E Unable to stop the deployment manager. Exiting."
stopWASServer ${ic1ServerName} ${ic1ProfileDir}
checkStatus ${?} "E Unable to stop the Connections application server. Exiting."
stopWASServer nodeagent ${ic1ProfileDir}
checkStatus ${?} "E Unable to stop the Connections node agent. Exiting." 

# Install the package
log "I Installing WebSphere Java SDK package..."
${imcl} -acceptLicense -log ${javaInstallLog} -repositories ${javaRepo} -installationDirectory ${wasInstallDir} install ${sdkIdVersion}
checkStatus ${?} "E Installation of WebSphere Java SDK failed."

# Get the latest SDK installed
latestSDK=$(${manageSDK} -listAvailable | ${grep} "SDK name:" | ${awk} '{print $4}' | ${sort} -n | ${tail} -1)

# Ensure the deployment manager is started
startWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E Unable to start deployment manager to update SDK. Exiting."

# Update the Java SDK for the deployment manager profile
log "I Enabling Java SDK ${latestSDK} for the deployment manager profile..."
${manageSDK} -enableProfile -profileName ${dmgrProfileName} -sdkname ${latestSDK} -user ${dmgrAdminUser} -password ${defaultPwd}
checkStatus ${?} "E Unable to update the Java SDK on the deployment manager. Exiting."

# Run a node agent sync
log "I Synchronizing node..."
syncWASNode
checkStatus ${?} "E Unable to synchronize the node. Exiting."

# Update the JVM for the application server profile 
log "I Enabling Java SDK ${latestSDK} for the application server profile..."
${manageSDK} -enableProfile -profileName ${ic1ProfileName} -sdkname ${latestSDK} -user ${dmgrAdminUser} -password ${defaultPwd}
checkStatus ${?} "E Unable to update the Java SDK on the Connections application server. Exiting."

# Restart all servers
log "I Restarting all WAS servers..."
restartAllWASServersWithNodeSync
checkStatus ${?} "E Unable to restart all WAS servers. Exiting."

# Update the default JVM for commands
${manageSDK} -setCommandDefault -sdkname ${latestSDK}
checkStatus ${?} "E Unable to update the default Java SDK for commands. Exiting."

logInstall 'WebSphere Java SDK Update' end
