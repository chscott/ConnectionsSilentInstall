#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
installDb2Script="${stagingDir}/src/db2/install.sh"
createDbsScript="${stagingDir}/src/ic/create_dbs.sh"
installIimScript="${stagingDir}/src/iim/install.sh"
installWebSphereScript="${stagingDir}/src/web/install.sh"
enableSSLScript="${stagingDir}/src/web/enable_ssl.sh"
createDmgrProfileScript="${stagingDir}/src/web/create_profile_dmgr.sh"
createAppSrvProfileScript="${stagingDir}/src/web/create_profile_appsrv.sh"
addLdapScript="${stagingDir}/src/web/add_ldap.sh"
confWebServerScript="${stagingDir}/src/web/config_webserver.sh"
installTdiScript="${stagingDir}/src/tdi/install.sh"
installConnectionsScript="${stagingDir}/src/ic/install.sh"
postInstallConnectionsScript="${stagingDir}/src/ic/post_install.sh"
error="exited with an error. Aborting install."

log "I Beginning installation of components..."

# Do initialization stuff
init main main_install

# Rotate logs
logRotate

# Install selected components 
if [ ${installDb2} == "true" ]; then
    ${installDb2Script}
    checkStatus ${?} "E DB2 installation failed. Exiting."
fi
if [ ${installTdi} == "true" ]; then
    ${installTdiScript}
    checkStatus ${?} "E TDI installation failed. Exiting."
fi
if [ ${installIim} == "true" ]; then
    ${installIimScript}
    checkStatus ${?} "E IIM installation failed. Exiting."
fi
if [ ${installWeb} == "true" ]; then
    ${installWebSphereScript}
    checkStatus ${?} "E WebSphere installation failed. Exiting."
    ${enableSSLScript}
    checkStatus ${?} "E Unable to configure SSL. Exiting."
    ${createDmgrProfileScript}
    checkStatus ${?} "E Unable to create deployment manager profile. Exiting."
    ${addLdapScript}
    checkStatus ${?} "E Unable to add LDAP to federated repository. Exiting."
    ${confWebServerScript}
    checkStatus ${?} "E Unable to create a new web server definition. Exiting."
    ${createAppSrvProfileScript}
    checkStatus ${?} "E Unable to create application server profile. Exiting."
fi
if [ ${installIc} == "true" ]; then
    ${createDbsScript}
    checkStatus ${?} "E Unable to create Connections databases. Exiting."
    ${installConnectionsScript}
    checkStatus ${?} "E Connections installation failed. Exiting."
    ${postInstallConnectionsScript}
    checkStatus ${?} "E Connections post-installation tasks failed. Exiting."
fi

log "I Success! Completed installation of components."
