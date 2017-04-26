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
    checkStatus ${?} "ERROR: Unable to uninstall WebSphere components. Please review ${scriptLog}, correct problem, and try again."
fi

if [ ${installIim} == "true" ]; then
    ${sudo} ${unInstallIimScript} 
    checkStatus ${?} "ERROR: Unable to uninstall IIM. Please review ${scriptLog}, correct problem, and try again."
fi

if [ ${installDb2} == "true" ]; then
    ${sudo} ${unInstallDb2Script} 
    checkStatus ${?} "ERROR: Unable to uninstall DB2 Please review ${scriptLog}, correct problem, and try again."
fi
