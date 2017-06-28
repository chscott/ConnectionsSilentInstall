#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
wsadmin="${dmgrProfileDir}/bin/wsadmin.sh"
options="${dmgrProfileDir}/config ${dmgrCellName} ${fqdn}-node ${webServerName}"

log "I Beginning propagation of web server plug-in keystore..."

# Do initialization stuff
init ${webStagingDir} configure

# Make sure deployment manager is started 
startWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E Unable to start deployment manager. Exiting."

# Invoke wsadmin to add the LDAP repository
log "I Propagating web server plug-in keystore..."
${wsadmin} \
    "-f" "${stagingDir}/src/web/propagate_keys.py" \
    "-lang" "jython" \
    "-user" "${dmgrAdminUser}" \
    "-password" "${defaultPwd}" \
    "${options}" >>${scriptLog} 2>&1
checkStatus ${?} "E Unable to propagate web server plug-in keystore. Exiting."

# Print the results
log "I Success! Web server plug-in keystore propagated."
