#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/web/web.conf

# Do initialization stuff
init web configure

logConfigure 'WebSphere LDAP' begin

# Check to make sure deployment manager is running
startWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E Deployment manager is not running. Exiting."

# See if the repository we want to add already exists
log "I Checking to see if ${ldapId} already exists in repository..."
${wsadmin} \
    "-f" "${stagingDir}/src/web/get_ldap.py" \
    "-lang" "jython" \
    "-user" "${dmgrAdminUser}" \
    "-password" "${defaultPwd}" \
    "${ldapId}"
result=${?}

# Add the repository if it doesn't already exist
if [ ${result} -eq 0 ]; then
    log "W WAS repository already contains ${ldapId} entry. Skipping."
else
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
        "${realmName}"
    checkStatus ${?} "E Unable to configure LDAP for WAS. Exiting."
fi

logConfigure 'WebSphere LDAP' end
