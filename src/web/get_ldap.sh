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

# Invoke wsadmin to add the LDAP repository
log "I Checking to see if ${ldapId} already exists in repository..."
${wsadmin} \
    "-f" "${stagingDir}/src/web/get_ldap.py" \
    "-lang" "jython" \
    "-user" "${dmgrAdminUser}" \
    "-password" "${defaultPwd}" \
    "${ldapId}"
log "I Result is ${?}"

logConfigure 'WebSphere LDAP' end
