#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Logs
db2UninstallLog="${stagingDir}/${db2StagingDir}/db2_uninstall.log"
db2UninstallTrace="${stagingDir}/${db2StagingDir}/db2_uninstall.trc"

# Directories
db2DataDir="/var/db2"
rsctInstallDir="/opt/rsct"

# Commands
db2Stop="/home/${db2InstanceUser}/sqllib/adm/db2stop"
db2Idrop="${db2InstallDir}/instance/db2idrop"
db2Uninstall="${db2StagingSubDir}/db2_deinstall -b ${db2InstallDir} -l ${db2UninstallLog} -t ${db2UninstallTrace} -r"

# Response file
db2UninstallResponseFile="${stagingDir}/responsefiles/db2_uninstall.rsp"

# Make sure script is running as root
checkForRoot

# First see if DB2 is even installed
result=$(isInstalled ${db2InstallDir})
if [ ${result} == 1 ]; then
    log "WARNING: DB2 does not appear to be installed. Exiting."
    exit 1
fi

# Proceed with the uninstall
cd ${stagingDir}/${db2StagingDir}

# Stop DB2
log "Stopping DB2..."
${su} - ${db2InstanceUser} -c "${db2Stop} >/dev/null 2>&1"; status=${?} >>${scriptLog} 2>&1
checkStatus ${status} "ERROR: Failed to stop DB2. Exiting."

# Drop the instance
log "Dropping instance ${db2InstanceName}..."
${db2Idrop} ${db2InstanceName} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Failed to drop instance ${db2InstanceName}. Exiting."

# Uninstall DB2
log "Uninstalling DB2..."
${db2Uninstall} ${db2UninstallResponseFile} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Failed to uninstall DB2. Exiting."

# Clean up install artifacts
log "Deleting ${db2InstallDir}..."
${rm} -f -r ${db2InstallDir} >>${scriptLog} 2>&1
checkStatus ${?} "WARNING: Failed to delete ${db2InstallDir}. Manual cleanup is required."
log "Deleting ${rsctInstallDir}..."
${rm} -f -r ${rsctInstallDir} >>${scriptLog} 2>&1
checkStatus ${?} "WARNING: Failed to delete ${rsctInstallDir}. Manual cleanup is required."
log "Deleting ${db2DataDir}..."
${rm} -f -r ${db2DataDir} >>${scriptLog} 2>&1
checkStatus ${?} "WARNING: Failed to delete ${db2DataDir}. Manual cleanup is required."

# Clean up users
log "Deleting user ${db2InstanceUser}..."
${userdel} -r ${db2InstanceUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2InstanceUser} "DELETE"
log "Deleting user ${db2FencedUser}..."
${userdel} -r ${db2FencedUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2FencedUser} "DELETE"
log "Deleting user ${db2DASUser}..."
${userdel} -r ${db2DASUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2DASUser} "DELETE"

# Clean up groups
log "Deleting group ${db2InstanceGroup}..."
${groupdel} ${db2InstanceGroup} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2InstanceGroup} "DELETE"
log "Deleting group ${db2FencedGroup}..."
${groupdel} ${db2FencedGroup} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2FencedGroup} "DELETE"
log "Deleting group ${db2DASGroup}..."
${groupdel} ${db2DASGroup} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "WARNING: Unable to delete" ${db2DASGroup} "DELETE"

# Print the results
log "SUCCESS! DB2 has been uninstalled."
