#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
installDb2Script="${stagingDir}/src/db2_install.sh"
createDbsScript="${stagingDir}/src/ic_create_dbs.sh"
installIimScript="${stagingDir}/src/iim_install.sh"
installWasScript="${stagingDir}/src/was_install.sh"
createDmgrProfileScript="${stagingDir}/src/was_create_profile_dmgr.sh"
addLdapScript="${stagingDir}/src/was_add_ldap.sh"
installTdiScript="${stagingDir}/src/tdi_install.sh"
error="exited with an error. Aborting install."

# Do initialization stuff
init main main_install

# Step 1: Install DB2, if requested
if [ ${installDb2} == "true" ]; then
    ${installDb2Script} 
    checkStatus "${?}" "ERROR: ${installDb2Script} ${error}" 
    ${createDbsScript}
fi

# Step 2: Install IIM, if requested
if [ ${installIim} == "true" ]; then
    ${installIimScript} 
    checkStatus "${?}" "ERROR: ${installIimScript} ${error}" 
fi

# Step 3: Install WAS, if requested
if [ ${installWas} == "true" ]; then
    ${installWasScript} 
    checkStatus "${?}" "ERROR: ${installWasScript} ${error}" 
    ${createDmgrProfileScript} 
    checkStatus "${?}" "ERROR: ${createDmgrProfileScript} ${error}" 
    ${addLdapScript}
    checkStatus "${?}" "ERROR: ${addLdapScript} ${error}" 
fi

# Step 4: Install TDI, if requested
if [ ${installTdi} == "true" ]; then
    ${installTdiScript}
    checkStatus "${?}" "ERROR: ${installTdiScript} ${error}"
fi
