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

# Assume it is OK to uninstall IIM. Failure to uninstall WAS will
# cause this to be set to false
okToUninstallIim="true"

if [ ${installWas} == "true" ]; then
    ${sudo} ${unInstallWasScript} 
    result=${?}
    # Don't try to uninstall IIM if WAS uninstall failed
    if [ ${result} -ne 0 ]; then
        log "WARNING: WAS uninstall failed. Will not attempt to uninstall IIM."
        okToUninstallIim="false"    
    fi
fi

if [ ${installIim} == "true" -a ${okToUninstallIim} == "true" ]; then
    ${sudo} ${unInstallIimScript} 
fi

if [ ${installDb2} == "true" ]; then
    ${sudo} ${unInstallDb2Script} 
fi
