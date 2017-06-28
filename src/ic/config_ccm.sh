#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables 
setJvmArgs="${stagingDir}/src/ic/set_jvm_args.sh"
createGCD="./createGCD.sh"
createObjectStore="./createObjectStore.sh"

log "I Beginning CCM configuration..."

# Do initialization stuff
init ${icStagingDir} configure 

# Update the Connections server's JVM process definition
log "I Updating Connections application server JVM..."
${setJvmArgs} >${scriptLog} 2>&1
checkStatus ${?} "E Unable to set JVM arguments for Connections application server. Exiting."

# Configure CCM
cd "${icInstallDir}/ccmDomainTool"
${clear}
log "The next step will create the FileNet P8 domain and Global Configuration Data."
${read} -p "You will be prompted to enter information for your environment. Press Enter to begin."
${createGCD}
checkStatus ${?} "E Unable to configure GCD. Exiting."
${clear}
log "The next step will create the FileNet object store and install add-ons."
${read} -p "You will be prompted to enter information for your environment. Press Enter to begin."
${createObjectStore}
checkStatus ${?} "E Unable to create object store. Exiting."
${clear}

# Restart the Connections application server
restartWASServer ${ic1ServerName} ${ic1ProfileDir}
checkStatus ${?} "E Unable to restart the Connections application server. Exiting."

log "I Success! CCM configuration tasks completed."
