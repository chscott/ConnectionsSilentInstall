#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Scripts
unInstallWasScript="${stagingDir}/src/was_uninstall.sh"
unInstallIimScript="${stagingDir}/src/iim_uninstall.sh"
unInstallDb2Script="${stagingDir}/src/db2_uninstall.sh"

# Make sure script is running as root
checkForRoot

# Reset the script log
log "Resetting script log ${scriptLog}..."
> ${scriptLog}
${chmod} a+rw ${scriptLog}

if [ ${installWas} == "true" ]; then
   ${sudo} ${unInstallWasScript} 
fi

if [ ${installIim} == "true" ]; then
   ${sudo} ${unInstallIimScript} 
fi

if [ ${installDb2} == "true" ]; then
   ${sudo} ${unInstallDb2Script} 
fi
