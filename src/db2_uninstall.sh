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
db2UninstallResponseFile="${stagingDir}/responsefiles/db2_uninstall.rsp"

# Do initialization stuff
init db2 uninstall

# First see if DB2 is even installed
result=$(isInstalled ${db2InstallDir})
if [ ${result} -eq  1 ]; then
    log "ERROR: DB2 does not appear to be installed. Exiting."
    exit 1
fi

# Stop DB2
log "Stopping DB2..."
${su} - ${db2InstanceUser} -c "${db2Stop} >/dev/null 2>&1"; result=${?}
if [ ${result} -ne 0 ]; then
    log "WARNING: Unable to stop DB2. DB2 may not be running. Continuing..."
fi

# Drop the instance
log "Dropping instance ${db2InstanceName}..."
result=$(${db2Idrop} ${db2InstanceName}) | ${grep} "completed successfully" 
if [ ${result} -ne 0 ]; then
    log "WARNING: Unable to drop instance ${db2InstanceName}. Instance may not exist. Continuing..."
fi

# Uninstall DB2
log "Uninstalling DB2..."
${db2Uninstall} ${db2UninstallResponseFile} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Failed to uninstall DB2. Exiting."

# Clean up install artifacts
log "Deleting ${db2InstallDir}..."
${rm} -f -r ${db2InstallDir}
log "Deleting ${rsctInstallDir}..."
${rm} -f -r ${rsctInstallDir}
log "Deleting ${tsampInstallDir}..."
${rm} -f -r ${tsampInstallDir}
log "Deleting ${db2DataDir}..."
${rm} -f -r ${db2DataDir}
log "Deleting user ${db2InstanceUser}..."
${userdel} -r ${db2InstanceUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2InstanceUser} "DELETE"
log "Deleting user ${db2FencedUser}..."
${userdel} -r ${db2FencedUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2FencedUser} "DELETE"
log "Deleting user ${db2DASUser}..."
${userdel} -r ${db2DASUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2DASUser} "DELETE"
log "Deleting group ${db2InstanceGroup}..."
${groupdel} ${db2InstanceGroup}
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2InstanceGroup} "DELETE"
log "Deleting group ${db2FencedGroup}..."
${groupdel} ${db2FencedGroup}
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2FencedGroup} "DELETE"
log "Deleting group ${db2DASGroup}..."
${groupdel} ${db2DASGroup}
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2DASGroup} "DELETE"

# Print the results
log "SUCCESS! DB2 has been uninstalled."
