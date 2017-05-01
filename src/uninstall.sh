#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Scripts
uninstallTdiScript="${stagingDir}/src/tdi_uninstall.sh"
uninstallWasScript="${stagingDir}/src/was_uninstall.sh"
uninstallIimScript="${stagingDir}/src/iim_uninstall.sh"
uninstallDb2Script="${stagingDir}/src/db2_uninstall.sh"

# Do initialization stuff
init main main_uninstall

# Assume it is OK to uninstall IIM. Failure to uninstall WAS will
# cause this to be set to false
okToUninstallIim="true"

if [ ${installTdi} == "true" ]; then
    ${uninstallTdiScript}
fi

if [ ${installWas} == "true" ]; then
    ${uninstallWasScript} 
    result=${?}
    # Don't try to uninstall IIM if WAS uninstall failed
    if [ ${result} -ne 0 ]; then
        log "WARNING: WAS uninstall failed. Will not attempt to uninstall IIM."
        okToUninstallIim="false"    
    fi
fi

if [ ${installIim} == "true" -a ${okToUninstallIim} == "true" ]; then
    ${uninstallIimScript} 
fi

if [ ${installDb2} == "true" ]; then
    ${uninstallDb2Script} 
fi
