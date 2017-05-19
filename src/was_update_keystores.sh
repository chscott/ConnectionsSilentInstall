#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
wsadmin="${dmgrProfileDir}/bin/wsadmin.sh"
scope="(cell):${dmgrCellName}:(node):${fqdn}-node:(server):${webServerName}"

log "INSTALL: Beginning update of web server plug-in keystore..."

# Do initialization stuff
init ${wasStagingDir} configure

# Make sure deployment manager is started 
dmgrStatus=$(startWASServer ${dmgrServerName} ${dmgrProfileDir})
checkStatus ${dmgrStatus} "ERROR: Unable to start deployment manager. Exiting."

# Invoke wsadmin to add the LDAP repository
log "INFO: Updating web server plug-in keystore..."
${wsadmin} \
    "-f" "${stagingDir}/src/was_update_keystores.py" \
    "-lang" "jython" \
    "-user" "${dmgrAdminUser}" \
    "-password" "${defaultPwd}" \
    "${fqdn}" \
    "9443" \
    "DELETE_ME" \
    "${scope}" \
    "CMSKeyStore" >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to update web server plug-in keystore. Exiting."

# Print the results
log "INSTALL: Success! Web server plug-in keystore has been updated."
