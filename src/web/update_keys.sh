#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/web/web.conf

# Do initialization stuff
init web configure

logConfigure 'Web Server Keystore Update' begin

# Make sure deployment manager is started 
startWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E Unable to start deployment manager. Exiting."

# Invoke wsadmin to add the LDAP repository
log "I Updating web server plug-in keystore..."
${wsadmin} \
    "-f" "${stagingDir}/src/web/update_keys.py" \
    "-lang" "jython" \
    "-user" "${dmgrAdminUser}" \
    "-password" "${defaultPwd}" \
    "${ihsFqdn}" \
    "9443" \
    "DELETE_ME" \
    "${scope}" \
    "CMSKeyStore"
checkStatus ${?} "E Unable to update web server plug-in keystore. Exiting."

logConfigure 'Web Server Keystore Update' end
