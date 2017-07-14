#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/web/web.conf

# Do initialization stuff
init ${webStagingDir} configure

logConfigure 'WAS Application Server Profile' begin

# See if the deployment manager profile already exists
result=$(isInstalled ${ic1ProfileDir})
if [ ${result} -eq 0 ]; then
    log "W Application Server profile already exists. Skipping."
else
    # Check to make sure deployment manager is running
    startWASServer ${dmgrServerName} ${dmgrProfileDir}
    checkStatus ${?} "E Deployment manager is not started. Exiting."
    # Create the application server profile
    log "I Creating Connections profile..."
    ${manageProfiles} \
        "-create" \
        "-templatePath" "${wasInstallDir}/profileTemplates/managed" \
        "-profileName" "${ic1ProfileName}" \
        "-profilePath" "${ic1ProfileDir}" \
        "-nodeName" "${ic1NodeName}" \
        "-cellName" "ic_cell" \
        "-hostName" "${ic1Fqdn}" \
        "-dmgrHost" "${dmgrFqdn}" \
        "-dmgrAdminUserName" "${dmgrAdminUser}" \
        "-dmgrAdminPassword" "${defaultPwd}"
    checkStatus ${?} "E Unable to create Connections profile. Exiting."
fi

logConfigure 'WAS Application Server Profile' end
