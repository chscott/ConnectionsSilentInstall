#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
plgResponseFileTemplate="${stagingDir}/rsp/was_plugin.tmp"
plgResponseFile="${stagingDir}/${wasStagingDir}/was_plugin.rsp"
wctpct="${wctInstallDir}/WCT/wctcmd.sh -tool pct"
configScript="configurewebserver1.sh"

# Do initialization stuff
init was configure

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
log "INFO: Generating the web server configuration script..."
${wctpct} -defLocPathName ${plgInstallDir} -defLocName plugins -createDefinition -response ${plgResponseFile} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to generate web server configuration script. Exiting."

# Copy the config script to the WAS bin directory
${cp} ${plgInstallDir}/bin/${configScript} ${wasInstallDir}/bin/${configScript} 

# Run the config script
log "INFO: Defining the web server configuration to the cell..."
${wasInstallDir}/bin/${configScript} -profileName ${dmgrProfileName} -user ${dmgrAdminUser} -password ${defaultPwd} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to define web server to the cell. Exiting."

# Print the results
log "INFO: Success! Web server has been defined to the cell."
