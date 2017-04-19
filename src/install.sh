#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Scripts
installDb2Script="${stagingDir}/src/db2_install.sh"
installIimScript="${stagingDir}/src/iim_install.sh"
installWasScript="${stagingDir}/src/was_install.sh"
createDmgrProfileScript="${stagingDir}/src/was_create_profile_dmgr.sh"
addLdapScript="${stagingDir}/src/was_add_ldap.sh"

# Make sure script is running as root
checkForRoot

# Reset the script log
log "Resetting script log ${scriptLog}..."
> ${scriptLog}
${chown} .users ${scriptLog}
${chmod} g+rw ${scriptLog}

if [ ${installDb2} == "true" ]; then
    ${installDb2Script} 
    checkStatus "${?}" "ERROR: ${installDb2Script} exited with an error. Aborting install." 
fi

if [ ${installIim} == "true" ]; then
    ${installIimScript} 
    checkStatus "${?}" "ERROR: ${installIimScript} exited with an error. Aborting install." 
fi

if [ ${installWas} == "true" ]; then
    ${installWasScript} 
    checkStatus "${?}" "ERROR: ${installWasScript} exited with an error. Aborting install." 
    ${createDmgrProfileScript} 
    checkStatus "${?}" "ERROR: ${createDmgrProfileScript} exited with an error. Manual profile creation may be necessary." 
    ${addLdapScript}
    checkStatus "${?}" "ERROR: ${addLdapScript} exited with an error. Aborting install." 
    
fi
