#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
manageProfiles="${wasInstallDir}/bin/manageprofiles.sh"

# Do initialization stuff
init ${wasStagingDir} configure

# Make sure deployment manager is started 
dmgrStatus=$(startWASServer ${dmgrServerName} ${dmgrProfileDir})
checkStatus ${dmgrStatus} "ERROR: Unable to start deployment manager. Exiting."

# Create the DMGR profile
log "INFO: Creating Connections profile..."
${manageProfiles} \
    "-create" \
    "-templatePath" "${wasInstallDir}/profileTemplates/managed" \
    "-profileName" "${icProfileName}" \
    "-profilePath" "${icProfileDir}" \
    "-nodeName" "${icNodeName}" \
    "-cellName" "ic_cell" \
    "-dmgrHost" "${fqdn}" \
    "-dmgrAdminUserName" "${dmgrAdminUser}" \
    "-dmgrAdminPassword" "${defaultPwd}" >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to create Connections profile. Exiting."

# Print the results
log "INFO: Success! A new Connections profile has been created."
