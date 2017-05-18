#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
uninstallTdiScript="${stagingDir}/src/tdi_uninstall.sh"
uninstallWasScript="${stagingDir}/src/was_uninstall.sh"
uninstallIimScript="${stagingDir}/src/iim_uninstall.sh"
uninstallDb2Script="${stagingDir}/src/db2_uninstall.sh"
uninstallIcScript="${stagingDir}/src/ic_uninstall.sh"
doIimUninstall="true"

# Do initialization stuff
init main main_uninstall

# Step 1: Uninstall TDI, if installed
if [ ${installTdi} == "true" ]; then
    ${uninstallTdiScript}
fi

# Step 2: Uninstall Connections, if installed
if [ ${installIc} == "true" ]; then
    ${uninstallIcScript}
    result=${?}
    # Don't try to uninstall IIM if Connections uninstall failed
    if [ ${result} -ne 0 ]; then
        log "WARNING: Connections uninstall failed. Will not attempt to uninstall IIM."
        doIimUninstall="false"    
    fi
fi

# Step 3: Uninstall WAS, if installed
if [ ${installWas} == "true" ]; then
    ${uninstallWasScript} 
    result=${?}
    # Don't try to uninstall IIM if WAS uninstall failed
    if [ ${result} -ne 0 ]; then
        log "WARNING: WAS uninstall failed. Will not attempt to uninstall IIM."
        doIimUninstall="false"    
    fi
fi

# Step 4: Uninstall IIM, if installed and it's OK to do so
if [ ${installIim} == "true" -a ${doIimUninstall} == "true" ]; then
    ${uninstallIimScript} 
fi

# Step 5: Uninstall DB2, if installed
if [ ${installDb2} == "true" ]; then
    ${uninstallDb2Script} 
fi
