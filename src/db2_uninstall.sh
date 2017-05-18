#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
db2UninstallLog="${logDir}/db2_uninstall.log"
db2UninstallTrace="${logDir}/db2_uninstall.trc"
db2DataDir="/var/db2"
rsctInstallDir="/opt/rsct"
tsampInstallDir="/opt/ibm/tsamp"
db2Stop="/home/${db2InstanceUser}/sqllib/adm/db2stop"
db2Idrop="${db2InstallDir}/instance/db2idrop"
db2Uninstall="${db2InstallDir}/install/db2_deinstall -l ${db2UninstallLog} -t ${db2UninstallTrace} -r"
db2UninstallResponseFile="${stagingDir}/rsp/db2_uninstall.rsp"
doUninstall="true"

# Do initialization stuff
init db2 uninstall

# First see if DB2 is even installed
result=$(isInstalled ${db2InstallDir})
if [ ${result} -eq  1 ]; then
    log "INFO: DB2 does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# Uninstall DB2
if [ ${doUninstall} == "true" ]; then

    # Stop DB2
    log "INFO: Stopping DB2..."
    ${su} - ${db2InstanceUser} -c "${db2Stop} >/dev/null 2>&1"; result=${?}
    if [ ${result} -ne 0 ]; then
        log "WARNING: Unable to stop DB2. DB2 may not be running. Continuing..."
    fi

    # Drop the instance
    log "INFO: Dropping instance ${db2InstanceName}..."
    result=$(${db2Idrop} ${db2InstanceName}) | ${grep} "completed successfully" 
    if [ ${result} -ne 0 ]; then
        log "WARNING: Unable to drop instance ${db2InstanceName}. Instance may not exist. Continuing..."
    fi

    # Run the uninstaller 
    log "INFO: Uninstalling DB2..."
    ${db2Uninstall} ${db2UninstallResponseFile} >>${scriptLog} 2>&1
    checkStatus ${?} "ERROR: Failed to uninstall DB2. Exiting."

fi

# Clean up install artifacts
log "INFO: Removing RSCT installation directory..."
${rm} -f -r ${rsctInstallDir}
log "INFO: Removing TSAMP installation directory..."
${rm} -f -r ${tsampInstallDir}
log "INFO: Removing DB2 installation directory..."
${rm} -f -r ${db2InstallDir}
log "INFO: Removing DB2 data directory..."
${rm} -f -r ${db2DataDir}
log "INFO: Removing user ${db2InstanceUser}..."
${userdel} -r ${db2InstanceUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to remove" ${db2InstanceUser} "DELETE"
log "INFO: Removing user ${db2FencedUser}..."
${userdel} -r ${db2FencedUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to remove" ${db2FencedUser} "DELETE"
log "INFO: Removing user ${db2DASUser}..."
${userdel} -r ${db2DASUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to remove" ${db2DASUser} "DELETE"
log "INFO: Removing user lcuser..."
${userdel} -r lcuser >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to remove" ${db2DASUser} "DELETE"
log "INFO: Removing group ${db2InstanceGroup}..."
${groupdel} ${db2InstanceGroup} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to remove" ${db2InstanceGroup} "DELETE"
log "INFO: Removing group ${db2FencedGroup}..."
${groupdel} ${db2FencedGroup} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to remove" ${db2FencedGroup} "DELETE"
log "INFO: Removing group ${db2DASGroup}..."
${groupdel} ${db2DASGroup} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to remove" ${db2DASGroup} "DELETE"

# Print the results
log "INFO: Success! DB2 has been uninstalled."
