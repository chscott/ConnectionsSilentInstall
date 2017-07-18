#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/db2/db2.conf

# Do initialization stuff
init db2 uninstall

logUninstall DB2 begin

# First see if DB2 is even installed
result=$(isInstalled ${db2InstallDir})
if [ ${result} -eq  1 ]; then
    log "I DB2 does not appear to be installed. Skipping uninstall."
    doUninstall="false"
fi

# Uninstall DB2
if [ ${doUninstall} == "true" ]; then

    # Stop DB2
    log "I Stopping DB2..."
    ${su} - ${db2InstanceUser} -c "${db2Stop} >/dev/null 2>&1"; result=${?}
    if [ ${result} -ne 0 ]; then
        log "W Unable to stop DB2. DB2 may not be running. Continuing..."
    fi

    # Drop the instance
    log "I Dropping instance ${db2InstanceName}..."
    result=$(${db2Idrop} ${db2InstanceName}) | ${grep} "completed successfully" 
    if [ ${result} -ne 0 ]; then
        log "W Unable to drop instance ${db2InstanceName}. Instance may not exist. Continuing..."
    fi

    # Run the uninstaller 
    log "I Uninstalling DB2..."
    ${db2Uninstall} ${db2UninstallResponseFile}
    checkStatus ${?} "E Failed to uninstall DB2. Exiting."

fi

# Clean up install artifacts
log "I Removing RSCT installation directory..."
${rm} -f -r ${rsctInstallDir}
log "I Removing TSAMP installation directory..."
${rm} -f -r ${tsampInstallDir}
log "I Removing DB2 installation directory..."
${rm} -f -r ${db2InstallDir}
log "I Removing DB2 data directory..."
${rm} -f -r ${db2DataDir}
log "I Removing user ${db2InstanceUser}..."
${userdel} -r ${db2InstanceUser}
checkUserGroupStatus ${?} "W Unable to remove" ${db2InstanceUser} "DELETE"
log "I Removing user ${db2FencedUser}..."
${userdel} -r ${db2FencedUser}
checkUserGroupStatus ${?} "W Unable to remove" ${db2FencedUser} "DELETE"
log "I Removing user ${db2DASUser}..."
${userdel} -r ${db2DASUser}
checkUserGroupStatus ${?} "W Unable to remove" ${db2DASUser} "DELETE"
log "I Removing user lcuser..."
${userdel} -r lcuser
checkUserGroupStatus ${?} "W Unable to remove" ${db2DASUser} "DELETE"
log "I Removing group ${db2InstanceGroup}..."
${groupdel} ${db2InstanceGroup}
checkUserGroupStatus ${?} "W Unable to remove" ${db2InstanceGroup} "DELETE"
log "I Removing group ${db2FencedGroup}..."
${groupdel} ${db2FencedGroup}
checkUserGroupStatus ${?} "W Unable to remove" ${db2FencedGroup} "DELETE"
log "I Removing group ${db2DASGroup}..."
${groupdel} ${db2DASGroup}
checkUserGroupStatus ${?} "W Unable to remove" ${db2DASGroup} "DELETE"

logUninstall DB2 end
