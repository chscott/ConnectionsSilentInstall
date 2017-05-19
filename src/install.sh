#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
installDb2Script="${stagingDir}/src/db2_install.sh"
createDbsScript="${stagingDir}/src/ic_create_dbs.sh"
installIimScript="${stagingDir}/src/iim_install.sh"
installWebSphereScript="${stagingDir}/src/websphere_install.sh"
enableSSLScript="${stagingDir}/src/ihs_enable_ssl.sh"
createDmgrProfileScript="${stagingDir}/src/was_create_profile_dmgr.sh"
createAppSrvProfileScript="${stagingDir}/src/was_create_profile_appsrv.sh"
addLdapScript="${stagingDir}/src/was_add_ldap.sh"
confWebServerScript="${stagingDir}/src/was_configure_webserver.sh"
installTdiScript="${stagingDir}/src/tdi_install.sh"
installConnectionsScript="${stagingDir}/src/ic_install.sh"
postInstallConnectionsScript="${stagingDir}/src/ic_post_install.sh"
error="exited with an error. Aborting install."

log "INFO: Beginning installation of components..."

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

# Step 2: Install TDI, if requested
if [ ${installTdi} == "true" ]; then
    ${installTdiScript}
    checkStatus "${?}" "ERROR: ${installTdiScript} ${error}"
fi

# Step 3: Install IIM, if requested
if [ ${installIim} == "true" ]; then
    ${installIimScript} 
    checkStatus "${?}" "ERROR: ${installIimScript} ${error}" 
fi

# Step 4: Install and configure WebSphere components, if requested and IIM is installed
iimIsInstalled=$(isInstalled ${iimInstallDir})
if [ ${installWas} == "true" -a ${iimIsInstalled} -eq 0 ]; then
    ${installWebSphereScript} 
    checkStatus "${?}" "ERROR: ${installWebSphereScript} ${error}" 
    ${enableSSLScript}
    checkStatus "${?}" "ERROR: ${enableSSLScript} ${error}" 
    ${createDmgrProfileScript} 
    checkStatus "${?}" "ERROR: ${createDmgrProfileScript} ${error}" 
    ${addLdapScript}
    checkStatus "${?}" "ERROR: ${addLdapScript} ${error}" 
    ${confWebServerScript}
    checkStatus "${?}" "ERROR: ${confWebServerScript} ${error}"
    ${createAppSrvProfileScript} 
    checkStatus "${?}" "ERROR: ${createAppSrvProfileScript} ${error}" 
fi

# Step 5: Install Connections, if requested and IIM and WAS are installed
wasIsInstalled=$(isInstalled ${iimInstallDir})
if [ ${installIc} == "true" -a ${iimIsInstalled} -eq 0 -a ${wasIsInstalled} -eq 0 ]; then
    ${installConnectionsScript} 
    checkStatus "${?}" "ERROR: ${installConnectionsScript} ${error}" 
    ${postInstallConnectionsScript}
    checkStatus "${?}" "ERROR: ${postInstallConnectionsScript} ${error}"
fi

log "INFO: Success! Completed installation of components."
