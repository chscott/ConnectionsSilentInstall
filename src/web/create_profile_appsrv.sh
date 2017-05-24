#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
manageProfiles="${wasInstallDir}/bin/manageprofiles.sh"

log "I Creating WAS application server profile..."

# Do initialization stuff
init ${webStagingDir} configure

# Check to make sure deployment manager is running
result=$(isWASServerRunning ${dmgrServerName} ${dmgrProfileDir})
checkStatus ${result} "E Deployment manager is not started. Exiting."

# Create the application server profile
log "I Creating Connections profile..."
${manageProfiles} \
    "-create" \
    "-templatePath" "${wasInstallDir}/profileTemplates/managed" \
    "-profileName" "${ic1ProfileName}" \
    "-profilePath" "${ic1ProfileDir}" \
    "-nodeName" "${ic1NodeName}" \
    "-cellName" "ic_cell" \
    "-dmgrHost" "${fqdn}" \
    "-dmgrAdminUserName" "${dmgrAdminUser}" \
    "-dmgrAdminPassword" "${defaultPwd}" >>${scriptLog} 2>&1
checkStatus ${?} "E Unable to create Connections profile. Exiting."

# Print the results
log "I Success! WAS application server profile has been created."
