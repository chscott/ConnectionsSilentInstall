#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
wsadmin="${dmgrProfilePath}/bin/wsadmin.sh"
stopManager="${dmgrProfilePath}/bin/stopManager.sh"
startManager="${dmgrProfilePath}/bin/startManager.sh"

# Do initialization stuff
init was configure

# Start Deployment Manager
log "INFO: Starting Deployment Manager..."
${startManager} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to start Deployment Manager. If it is already running, stop it and re-run this script."

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
log "INFO: Restarting Deployment Manager..."
${stopManager} "-user" "${dmgrAdminUser}" "-password" "${defaultPwd}" >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to stop Deployment Manager. Please restart the Deployment Manager manually to complete configuration."
${startManager} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to start Deployment Manager. Please restart the Deployment Manager manually to complete configuration."

# Print the results
log "INFO: Success! LDAP has been configured for WAS."
