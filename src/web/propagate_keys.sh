#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/web/web.conf

# Do initialization stuff
init web configure

logConfigure 'Web Server Keystore Propagation' begin

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
    "${propagateKeysOptions}"
checkStatus ${?} "E Unable to propagate web server plug-in keystore. Exiting."

# Restart the web server to load the updated plug-in
restartIHSServer
result=${?}
if [ ${result} -ne 0 ]; then
    log "W Manual IHS restart required. Continuing..."
fi

logConfigure 'Web Server Keystore Propagation' end
