#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/web/web.conf

# Do initialization stuff
init web configure

logConfigure 'Web Server Definition' begin

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
${sed} -i "s|IHS_HOSTNAME|${ihsFqdn}|" ${plgResponseFile}

# Generate the config script
log "I Generating the web server configuration script..."
${wctpct} -defLocPathname ${plgInstallDir} -defLocName plugins -importDefinitionLocation -response ${plgResponseFile}
checkStatus ${?} "E Unable to generate web server configuration script. Exiting."

# Copy the config script to the WAS bin directory
${cp} -f ${plgInstallDir}/bin/${configScript} ${wasInstallDir}/bin/${configScript} 
checkStatus ${?} "E Unable to copy ${plgInstallDir}/bin/${configScript} to ${wasInstallDir}/bin/${configScript}. Exiting."

# Run the config script
log "I Defining the web server configuration to the cell..."
${wasInstallDir}/bin/${configScript} -profileName ${dmgrProfileName} -user ${dmgrAdminUser} -password ${defaultPwd}
checkStatus ${?} "E unable to define web server to the cell. Exiting."

logConfigure 'Web Server Definition' end
