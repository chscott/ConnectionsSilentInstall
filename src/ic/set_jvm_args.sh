#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/ic/ic.conf

# Do initialization stuff
init ${icStagingDir} configure

logConfigure 'Connections JVM Arguments' begin

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
    "${jvmArgument}"

# Print the results
result=${?}
if [ ${result} -ne 0 ]; then
    log "W Unable to update JVM arguments for Connections server. Manual update required."
else
    log "I Connections JVM arguments updated."
fi

logConfigure 'Connections JVM Arguments' end
