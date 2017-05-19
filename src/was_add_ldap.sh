#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
wsadmin="${dmgrProfileDir}/bin/wsadmin.sh"
stopManager="${dmgrProfileDir}/bin/stopManager.sh"
startManager="${dmgrProfileDir}/bin/startManager.sh"

# Do initialization stuff
init ${wasStagingDir} configure

# Make sure deployment manager is started 
result=$(startWASServer ${dmgrServerName} ${dmgrProfileDir})
checkStatus ${result} "ERROR: Unable to start deployment manager. Exiting."

# Invoke wsadmin to add the LDAP repository
log "INFO: Adding LDAP repository to Deployment Manager..."
${wsadmin} \
    "-f" "${stagingDir}/src/was_add_ldap.py" \
    "-lang" "jython" \
    "-user" "${dmgrAdminUser}" \
    "-password" "${defaultPwd}" \
    "${ldapType}" \
    "${ldapId}" \
    "${ldapHost}" \
    "${ldapPort}" \
    "${ldapBindDn}" \
    "${ldapBindPwd}" \
    "${ldapBase}" \
    "${loginProperties}" \
    "${realmName}" >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to configure LDAP for WAS. Exiting."

# Restart the Deployment Manager
result=$(restartWASServer ${dmgrServerName} ${dmgrProfileDir})
checkStatus ${result} "ERROR: Unable to restart deployment manager. Exiting."

# Print the results
log "INFO: Success! LDAP has been configured for WAS."
