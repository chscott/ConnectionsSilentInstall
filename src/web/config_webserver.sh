#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
plgResponseFileTemplate="${stagingDir}/rsp/web_plugin.tmp"
plgResponseFile="${stagingDir}/${webStagingDir}/web_plugin.rsp"
wctpct="${wctInstallDir}/WCT/wctcmd.sh -tool pct"
configScript="configurewebserver1.sh"
webTempDir="/root/.ibm"

log "I Configuring web server for WAS..."

# Do initialization stuff
init ${webStagingDir} configure

# Make sure the deployment manager is started
startWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E The deployment manager is not started. Exiting."

# Delete the WebSphere temp directory so the wctcmd commands will run without error
${rm} -f -r ${webTempDir} 

# Build the response file
copyTemplate ${plgResponseFileTemplate} ${plgResponseFile}
${sed} -i "s|IHS_ADMIN_GROUP|${ihsAdminGroup}|" ${plgResponseFile}
${sed} -i "s|IHS_ADMIN_USER|${ihsAdmin}|" ${plgResponseFile}
${sed} -i "s|IHS_ADMIN_PWD|${defaultPwd}|" ${plgResponseFile}
${sed} -i "s|WAS_PROFILE|${dmgrProfileName}|" ${plgResponseFile}
${sed} -i "s|WAS_INSTALL_DIR|${wasInstallDir}|" ${plgResponseFile}
${sed} -i "s|IHS_INSTALL_DIR|${ihsInstallDir}|" ${plgResponseFile}
${sed} -i "s|IHS_HOSTNAME|${fqdn}|" ${plgResponseFile}

# Generate the config script
log "I Generating the web server configuration script..."
${wctpct} -defLocPathname ${plgInstallDir} -defLocName plugins -importDefinitionLocation -response ${plgResponseFile} >>${scriptLog} 2>&1
checkStatus ${?} "E Unable to generate web server configuration script. Exiting."

# Copy the config script to the WAS bin directory
${cp} ${plgInstallDir}/bin/${configScript} ${wasInstallDir}/bin/${configScript} 

# Run the config script
log "I Defining the web server configuration to the cell..."
${wasInstallDir}/bin/${configScript} -profileName ${dmgrProfileName} -user ${dmgrAdminUser} -password ${defaultPwd} >>${scriptLog} 2>&1
checkStatus ${?} "E unable to define web server to the cell. Exiting."

# Print the results
log "I Success! Web server has been configured for WAS."
