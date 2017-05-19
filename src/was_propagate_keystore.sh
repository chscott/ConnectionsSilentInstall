#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
wsadmin="${dmgrProfileDir}/bin/wsadmin.sh"
options="${dmgrProfileDir}/config ${dmgrCellName} ${fqdn}-node ${webServerName}"

log "INSTALL: Beginning propagation of web server plug-in keystore..."

# Do initialization stuff
init ${wasStagingDir} configure

# Make sure deployment manager is started 
dmgrStatus=$(startWASServer ${dmgrServerName} ${dmgrProfileDir})
checkStatus ${dmgrStatus} "ERROR: Unable to start deployment manager. Exiting."

# Invoke wsadmin to add the LDAP repository
log "INFO: Propagating web server plug-in keystore..."
${wsadmin} \
    "-f" "${stagingDir}/src/was_propagate_keystore.py" \
    "-lang" "jython" \
    "-user" "${dmgrAdminUser}" \
    "-password" "${defaultPwd}" \
    "${options}" >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to propagate web server plug-in keystore. Exiting."

# Print the results
log "INSTALL: Success! Web server plug-in keystore propagated."
