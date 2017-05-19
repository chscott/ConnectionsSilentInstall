#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
manageProfiles="${wasInstallDir}/bin/manageprofiles.sh"

# Do initialization stuff
init ${wasStagingDir} configure

# Create the DMGR profile
log "INFO: Creating DMGR profile..."
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
checkStatus ${?} "ERROR: Unable to create DMGR profile. Exiting."

# Print the results
log "INFO: Success! A new DMGR profile has been created."
