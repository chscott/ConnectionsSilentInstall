#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
wsadmin="${dmgrProfileDir}/bin/wsadmin.sh"
stopManager="${dmgrProfileDir}/bin/stopManager.sh"
startManager="${dmgrProfileDir}/bin/startManager.sh"

log "I Configuring LDAP for WAS..."

# Do initialization stuff
init ${webStagingDir} configure

# Check to make sure deployment manager is running
startWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E Deployment manager is not running. Exiting."

# Invoke wsadmin to add the LDAP repository
log "I Adding LDAP repository to Deployment Manager..."
${wsadmin} \
    "-f" "${stagingDir}/src/web/add_ldap.py" \
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
checkStatus ${?} "E Unable to configure LDAP for WAS. Exiting."

# Print the results
log "I Success! LDAP has been configured for WAS."
