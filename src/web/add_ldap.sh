#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/web/web.conf

# Do initialization stuff
init ${webStagingDir} configure

logConfigure 'WebSphere LDAP' begin

# Check to make sure deployment manager is running
startWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E Deployment manager is not running. Exiting."

# See if the repository we want to add already exists
${getLdapScript}
result=${?}
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
