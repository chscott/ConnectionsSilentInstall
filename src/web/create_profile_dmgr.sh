#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/web/web.conf

# Do initialization stuff
init ${webStagingDir} configure

logConfigure 'WAS Deployment Manager Profile' begin

# See if the deployment manager profile already exists
result=$(isInstalled ${dmgrProfileDir})
if [ ${result} -eq 0 ]; then
    log "W Deployment Manager profile already exists. Skipping."
else
    # Create the DMGR profile
    log "I Creating DMGR profile..."
    ${manageProfiles} \
        "-create" \
        "-templatePath" "${wasInstallDir}/profileTemplates/management" \
        "-serverType" "DEPLOYMENT_MANAGER" \
        "-profileName" "${dmgrProfileName}" \
        "-profilePath" "${dmgrProfileDir}" \
        "-nodeName" "${dmgrNodeName}" \
        "-cellName" "${dmgrCellName}" \
        "-serverName" "${dmgrServerName}" \
        "-hostName" "${dmgrFqdn}" \
        "-enableAdminSecurity" "true" \
        "-adminUserName" "${dmgrAdminUser}" \
        "-adminPassword" "${defaultPwd}"
    checkStatus ${?} "E Unable to create DMGR profile. Exiting."
fi

logConfigure 'WAS Deployment Manager Profile' end
