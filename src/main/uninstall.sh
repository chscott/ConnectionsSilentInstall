#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
uninstallTdiScript="${stagingDir}/src/tdi/uninstall.sh"
uninstallWebSphereScript="${stagingDir}/src/web/uninstall.sh"
uninstallIimScript="${stagingDir}/src/iim/uninstall.sh"
uninstallDb2Script="${stagingDir}/src/db2/uninstall.sh"
uninstallIcScript="${stagingDir}/src/ic/uninstall.sh"
doIimUninstall="true"
zerogRegistry="/var/.com.zerog.registry.xml"

log "I Beginning uninstall of components..."

# Do initialization stuff
init main main_uninstall

# Step 1: Uninstall Connections, if installed
icInstalled=$(isInstalled ${icInstallDir})
if [ ${icInstalled} -eq 0 ]; then
    ${uninstallIcScript}
    result=${?}
    # Don't try to uninstall IIM if Connections uninstall failed
    if [ ${result} -ne 0 ]; then
        log "W Connections uninstall failed. Will not attempt to uninstall IIM. Check log for details."
        doIimUninstall="false"    
    fi
fi

# Step 2: Uninstall WebSphere components, if installed
webInstalled=$(isInstalled ${webInstallDir})
if [ ${webInstalled} -eq 0 ]; then
    ${uninstallWebSphereScript} 
    result=${?}
    # Don't try to uninstall IIM if WebSphere uninstall failed
    if [ ${result} -ne 0 ]; then
        log "W WebSphere uninstall failed. Will not attempt to uninstall IIM. Check log for details."
        doIimUninstall="false"    
    fi
fi

# Step 3: Uninstall IIM, if installed and it's OK to do so
if [ ${doIimUninstall} == "true" ]; then
    iimInstalled=$(isInstalled ${iimInstallDir})
    if [ ${iimInstalled} -eq 0 ]; then
        ${uninstallIimScript} 
        result=${?}
        if [ ${result} -ne 0 ]; then
            log "W IIM uninstall failed. Check log for details." 
        fi
    fi
fi

# Step 4: Uninstall TDI, if installed
tdiInstalled=$(isInstalled ${tdiInstallDir})
if [ ${tdiInstalled} -eq 0 ]; then
    ${uninstallTdiScript}
    result=${?}
    if [ ${result} -ne 0 ]; then
        log "W TDI uninstall failed. Check log for details." 
    fi
fi

# Step 5: Uninstall DB2, if installed
db2Installed=$(isInstalled ${db2InstallDir})
if [ ${db2Installed} -eq 0 ]; then
    ${uninstallDb2Script} 
    result=${?}
    if [ ${result} -ne 0 ]; then
        log "W DB2 uninstall failed. Check log for details." 
    fi
fi

# Step 6: Misc
${rm} -f ${zerogRegistry}
${rm} -f -r ${childProcessTempDir}

log "I Success! Completed uninstall of components."
