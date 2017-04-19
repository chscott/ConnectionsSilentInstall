#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Commands
manageProfiles="${wasInstallDir}/bin/manageprofiles.sh"

# Make sure script is running as root
checkForRoot

# Create the DMGR profile
log "Creating DMGR profile..."
${manageProfiles} \
    "-create" \
    "-templatePath" "${wasInstallDir}/profileTemplates/management" \
    "-serverType" "DEPLOYMENT_MANAGER" \
    "-profileName" "${dmgrProfileName}" \
    "-profilePath" "${dmgrProfilePath}" \
    "-nodeName" "${dmgrNodeName}" \
    "-cellName" "${dmgrCellName}" \
    "-serverName" "${dmgrServerName}" \
    "-enableAdminSecurity" "true" \
    "-adminUserName" "${dmgrAdminUser}" \
    "-adminPassword" "${defaultPwd}" >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to create DMGR profile. Exiting."

# Print the results
log "SUCCESS! A new DMGR profile has been created."
