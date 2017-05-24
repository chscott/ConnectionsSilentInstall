#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
wsadmin="${dmgrProfileDir}/bin/wsadmin.sh"
scope="(cell):${dmgrCellName}:(node):${fqdn}-node:(server):${webServerName}"

log "I Beginning update of web server plug-in keystore..."

# Do initialization stuff
init ${webStagingDir} configure

# Make sure deployment manager is started 
dmgrStatus=$(startWASServer ${dmgrServerName} ${dmgrProfileDir})
checkStatus ${dmgrStatus} "E Unable to start deployment manager. Exiting."

# Invoke wsadmin to add the LDAP repository
log "I Updating web server plug-in keystore..."
${wsadmin} \
    "-f" "${stagingDir}/src/web/update_keys.py" \
    "-lang" "jython" \
    "-user" "${dmgrAdminUser}" \
    "-password" "${defaultPwd}" \
    "${fqdn}" \
    "9443" \
    "DELETE_ME" \
    "${scope}" \
    "CMSKeyStore" >>${scriptLog} 2>&1
checkStatus ${?} "E Unable to update web server plug-in keystore. Exiting."

# Print the results
log "I Success! Web server plug-in keystore has been updated."
