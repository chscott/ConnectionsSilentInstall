#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/ic/ic.conf

# Do initialization stuff
init ic configure 

logConfigure CCM begin

# Update the Connections server's JVM process definition
log "I Updating Connections application server JVM..."
${setJvmArgs}
checkStatus ${?} "E Unable to set JVM arguments for Connections application server. Exiting."

# Configure CCM if it hasn't already been configured
if [ ! -e ${gcdOK} -a ! -e ${objectStoreOK} ]; then
    cd "${icInstallDir}/ccmDomainTool"
    ${echo}
    log "****************************************************************************************************************"
    log "I Beginning CCM configuration. The following steps will require user input. Press Enter to begin."
    ${read} -p ""
    resetOutput
    ${createGCD}
    redirectOutput
    checkStatus ${?} "E Unable to configure GCD. Exiting."
    resetOutput
    ${createObjectStore}
    redirectOutput
    checkStatus ${?} "E Unable to create object store. Exiting."
    log "I CCM configuration complete."
    log "****************************************************************************************************************"
    ${echo}
else
    log "W CCM has already been configured. Skipping."
fi

# Restart the Connections application server
restartWASServer ${ic1ServerName} ${ic1ProfileDir}
checkStatus ${?} "E Unable to restart the Connections application server. Exiting."

logConfigure CCM end
