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

####################################################################################################
# Dependency level 0

log "I Running dependency level 0 tasks..."

resetChildProcessTempDir ${childProcessTempDir}

# Run background tasks
if [ ${installDb2} == "true" ]; then
    { ${installDb2Script}; ${echo} ${?} >${childProcessTempDir}/${BASHPID}; } &
fi
if [ ${installTdi} == "true" ]; then
    { ${installTdiScript}; ${echo} ${?} >${childProcessTempDir}/${BASHPID}; } &
fi
if [ ${installIim} == "true" ]; then
    { ${installIimScript}; ${echo} ${?} >${childProcessTempDir}/${BASHPID}; } &
fi

# Wait for background task completion and check results
wait
checkChildProcessStatus ${childProcessTempDir}
####################################################################################################

####################################################################################################
# Dependency level 1

log "I Running dependency level 1 tasks..."

resetChildProcessTempDir ${childProcessTempDir}

# Run background tasks
if [ ${installWeb} == "true" ]; then
    { ${installWebSphereScript}; ${echo} ${?} >${childProcessTempDir}/${BASHPID}; } &
fi

# Wait for background task completion and check results
wait
checkChildProcessStatus ${childProcessTempDir}
####################################################################################################

####################################################################################################
# Dependency level 2

log "I Running dependency level 2 tasks..."

resetChildProcessTempDir ${childProcessTempDir}

# Run background tasks
if [ ${installWeb} == "true" ]; then
    { ${enableSSLScript}; ${echo} ${?} >${childProcessTempDir}/${BASHPID}; } &
    { ${createDmgrProfileScript}; ${echo} ${?} >${childProcessTempDir}/${BASHPID}; } &
fi
if [ ${installIc} == "true" ]; then
    { ${createDbsScript}; ${echo} ${?} >${childProcessTempDir}/${BASHPID}; } &
fi

# Wait for background task completion and check results
wait
checkChildProcessStatus ${childProcessTempDir}
####################################################################################################

####################################################################################################
# Dependency level 3
# These tasks require that the deployment manager is started.

log "I Running dependency level 3 tasks..."

resetChildProcessTempDir ${childProcessTempDir}

if [ ${installWeb} == "true" ]; then

    # Start deployment manager
    status=$(startWASServer ${dmgrServerName} ${dmgrProfileDir})
    checkStatus ${status} "E Unable to start deployment manager. Exiting."

    # Run background tasks
    { ${addLdapScript}; ${echo} ${?} >${childProcessTempDir}/${BASHPID}; } &
    { ${confWebServerScript}; ${echo} ${?} >${childProcessTempDir}/${BASHPID}; } &
    { ${createAppSrvProfileScript}; ${echo} ${?} >${childProcessTempDir}/${BASHPID}; } &

    # Wait for background task completion and check results
    wait
    checkChildProcessStatus ${childProcessTempDir}

    # Restart deployment manager
    status=$(restartWASServer ${dmgrServerName} ${dmgrProfileDir})
    checkStatus ${status} "E Unable to restart deployment manager. Exiting."

fi
####################################################################################################

####################################################################################################
# Dependency level 4

log "I Running dependency level 4 tasks..."

resetChildProcessTempDir ${childProcessTempDir}

if [ ${installIc} == "true" ]; then
    
    # Run background tasks
    { ${installConnectionsScript}; echo ${?} >${childProcessTempDir}/${BASHPID}; } &

    # Wait for background task completion and check results
    wait
    checkChildProcessStatus ${childProcessTempDir}

fi
####################################################################################################

####################################################################################################
# Dependency level 5

log "I Running dependency level 5 tasks..."

resetChildProcessTempDir ${childProcessTempDir}

if [ ${installIc} == "true" ]; then

    # Run background tasks
    { ${postInstallConnectionsScript}; echo ${?} >${childProcessTempDir}/${BASHPID}; } &

    # Wait for background task completion and check results
    wait
    checkChildProcessStatus ${childProcessTempDir}

fi
####################################################################################################

log "I Success! Completed installation of components."
