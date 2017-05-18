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
enableSSLScript="${stagingDir}/src/ihs_enable_ssl.sh"
createDmgrProfileScript="${stagingDir}/src/was_create_profile_dmgr.sh"
createAppSrvProfileScript="${stagingDir}/src/was_create_profile_appsrv.sh"
addLdapScript="${stagingDir}/src/was_add_ldap.sh"
confPlgScript="${stagingDir}/src/was_configure_plugin.sh"
installTdiScript="${stagingDir}/src/tdi_install.sh"
installConnectionsScript="${stagingDir}/src/ic_install.sh"
error="exited with an error. Aborting install."

# Do initialization stuff
init main main_install

# Rotate logs
logRotate

# Step 1: Install DB2, if requested
if [ ${installDb2} == "true" ]; then
    ${installDb2Script} 
    checkStatus "${?}" "ERROR: ${installDb2Script} ${error}" 
    ${createDbsScript}
    checkStatus "${?}" "ERROR: ${createDbsScript} ${error}" 
fi

# Step 2: Install IIM, if requested
if [ ${installIim} == "true" ]; then
    ${installIimScript} 
    checkStatus "${?}" "ERROR: ${installIimScript} ${error}" 
fi

# Step 3: Install and configure WebSphere components, if requested
if [ ${installWas} == "true" ]; then
    ${installWasScript} 
    checkStatus "${?}" "ERROR: ${installWasScript} ${error}" 
    ${enableSSLScript}
    checkStatus "${?}" "ERROR: ${enableSSLScript} ${error}" 
    ${createDmgrProfileScript} 
    checkStatus "${?}" "ERROR: ${createDmgrProfileScript} ${error}" 
    ${addLdapScript}
    checkStatus "${?}" "ERROR: ${addLdapScript} ${error}" 
    ${confPlgScript}
    checkStatus "${?}" "ERROR: ${confPlgScript} ${error}"
    ${createAppSrvProfileScript} 
    checkStatus "${?}" "ERROR: ${createAppSrvProfileScript} ${error}" 
    ${installConnectionsScript} 
    checkStatus "${?}" "ERROR: ${installConnectionsScript} ${error}" 
fi

# Step 4: Install TDI, if requested
if [ ${installTdi} == "true" ]; then
    ${installTdiScript}
    checkStatus "${?}" "ERROR: ${installTdiScript} ${error}"
fi

