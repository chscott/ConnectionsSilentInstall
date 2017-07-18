#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/main/main.conf

# Do initialization stuff
init main main_uninstall

logUninstall 'All Components' begin

# Step 1: Uninstall Connections, if installed
icInstalled=$(isInstalled ${icInstallDir})
if [ ${icInstalled} -eq 0 ]; then
    ${uninstallIcScript}
    checkStatus ${?} "E Connections uninstall failed. Exiting."
else
    log "W Connections does not appear to be installed. Skipping."
fi

# Step 2: Uninstall WebSphere components, if installed
webInstalled=$(isInstalled ${webInstallDir})
if [ ${webInstalled} -eq 0 ]; then
    ${uninstallWebScript} 
    checkStatus ${?} "E WebSphere uninstall failed. Exiting."
else
    log "W WebSphere components do not appear to be installed. Skipping."
fi

# Step 3: Uninstall IIM, if installed and it's OK to do so
iimInstalled=$(isInstalled ${iimInstallDir})
if [ ${iimInstalled} -eq 0 ]; then
    ${uninstallIimScript} 
    checkStatus ${?} "E Installation Manager uninstall failed. Exiting."
else
    log "W IIM does not appear to be installed. Skipping."
fi

# Step 4: Uninstall TDI, if installed
tdiInstalled=$(isInstalled ${tdiInstallDir})
if [ ${tdiInstalled} -eq 0 ]; then
    ${uninstallTdiScript}
    checkStatus ${?} "E TDI uninstall failed. Exiting."
else
    log "W TDI does not appear to be installed. Skipping."
fi

# Step 5: Uninstall DB2, if installed
db2Installed=$(isInstalled ${db2InstallDir})
if [ ${db2Installed} -eq 0 ]; then
    ${uninstallDb2Script} 
    checkStatus ${?} "E DB2 uninstall failed. Exiting."
else
    log "W DB2 does not appear to be installed. Skipping."
fi

# Step 6: Misc
${rm} -f ${zerogRegistry}
${rm} -f -r ${childProcessTempDir}

logUninstall 'All Components' end
