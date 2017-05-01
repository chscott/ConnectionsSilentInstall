#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
installDb2Script="${stagingDir}/src/db2_install.sh"
installIimScript="${stagingDir}/src/iim_install.sh"
installWasScript="${stagingDir}/src/was_install.sh"
createDmgrProfileScript="${stagingDir}/src/was_create_profile_dmgr.sh"
addLdapScript="${stagingDir}/src/was_add_ldap.sh"
installTdiScript="${stagingDir}/src/tdi_install.sh"
error="exited with an error. Aborting install."

# Do initialization stuff
init main main_install

if [ ${installDb2} == "true" ]; then
    ${installDb2Script} 
    checkStatus "${?}" "ERROR: ${installDb2Script} ${error}" 
fi

if [ ${installIim} == "true" ]; then
    ${installIimScript} 
    checkStatus "${?}" "ERROR: ${installIimScript} ${error}" 
fi

if [ ${installWas} == "true" ]; then
    ${installWasScript} 
    checkStatus "${?}" "ERROR: ${installWasScript} ${error}" 
    ${createDmgrProfileScript} 
    checkStatus "${?}" "ERROR: ${createDmgrProfileScript} ${error}" 
    ${addLdapScript}
    checkStatus "${?}" "ERROR: ${addLdapScript} ${error}" 
    
fi

if [ ${installTdi} == "true" ]; then
    ${installTdiScript}
    checkStatus "${?}" "ERROR: ${installTdiScript} ${error}"
fi
