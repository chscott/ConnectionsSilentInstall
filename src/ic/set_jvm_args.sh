#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
wsadmin="${dmgrProfileDir}/bin/wsadmin.sh"
stopManager="${dmgrProfileDir}/bin/stopManager.sh"
startManager="${dmgrProfileDir}/bin/startManager.sh"
userPrincipal=$(${echo} ${loginProperties} | ${cut} -d ';' -f 1)
jvmArgument="-Dcom.ibm.connections.directory.services.j2ee.security.principal=${userPrincipal}"

# Do initialization stuff
init ${icStagingDir} configure

# Check to make sure deployment manager is running
startWASServer ${dmgrServerName} ${dmgrProfileDir}
checkStatus ${?} "E Deployment manager is not running. Exiting."

# Invoke wsadmin to update the JVM properties 
log "I Updating JVM arguments for Connections server..."
${wsadmin} \
    "-f" "${stagingDir}/src/ic/set_jvm_args.py" \
    "-lang" "jython" \
    "-user" "${dmgrAdminUser}" \
    "-password" "${defaultPwd}" \
    "${ic1ServerName}" \
    "${jvmArgument}" >>${scriptLog} 2>&1

# Print the results
result=${?}
if [ ${result} -ne 0 ]; then
    log "W Unable to update JVM arguments for Connections server. Manual update required."
else
    log "I Success! Connections JVM arguments updated."
fi
