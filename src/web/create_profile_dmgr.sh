#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
manageProfiles="${wasInstallDir}/bin/manageprofiles.sh"

log "I Creating WAS deployment manager profile..."

# Do initialization stuff
init ${webStagingDir} configure

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
    "-enableAdminSecurity" "true" \
    "-adminUserName" "${dmgrAdminUser}" \
    "-adminPassword" "${defaultPwd}" >>${scriptLog} 2>&1
checkStatus ${?} "E Unable to create DMGR profile. Exiting."

# Print the results
log "I Success! WAS deployment manager profile has been created."
