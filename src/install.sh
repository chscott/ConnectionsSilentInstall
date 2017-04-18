#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Scripts
installDb2Script="${stagingDir}/src/db2_install.sh"
installIimScript="${stagingDir}/src/iim_install.sh"
installWasScript="${stagingDir}/src/was_install.sh"

# Make sure script is running as root
checkForRoot

# Reset the script log
log "Resetting script log ${scriptLog}..."
> ${scriptLog}
${chown} .users ${scriptLog}
${chmod} g+rw ${scriptLog}

if [ ${installDb2} == "true" ]; then
   ${installDb2Script} 
fi

if [ ${installIim} == "true" ]; then
   ${installIimScript} 
fi

if [ ${installWas} == "true" ]; then
   ${installWasScript} 
fi
