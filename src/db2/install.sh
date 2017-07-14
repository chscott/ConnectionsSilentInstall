#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/db2/db2.conf

# Do initialization stuff
init ${db2StagingDir} install

logInstall DB2 begin 

# Download and unpack the install files 
log "I Downloading DB2 install files..."
{ ${downloadFile} ${ftpServer} ${ftpDB2Dir} ${db2InstallPackage}; ${echo} ${?} >${childProcessTempDir}/${db2StagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpDB2Dir} ${db2LicensePackage}; ${echo} ${?} >${childProcessTempDir}/${db2StagingDir}/${BASHPID}; } &
wait
checkChildProcessStatus ${childProcessTempDir}/${db2StagingDir}
resetChildProcessTempDir ${childProcessTempDir}/${db2StagingDir}
unpackFile tar "${db2InstallPackage}"
unpackFile zip "${db2LicensePackage}"

# Check DB2 prereqs
log "I Checking DB2 prerequisites..."
${db2Prereq}
${grep} ${db2PrereqSuccess} ${db2PrereqReport}
checkStatus ${?} "E DB2 prereq check failed. Review ${db2PrereqReport} and address any reported issues before proceeding."
${db2SAMPrereq}
checkStatus ${?} "E DB2 SAM prereq check failed. Review ${db2SAMPrereqReport} and address any reported issues before proceeding."

# Add required groups/users
log "I Creating DB2 groups..."
${sysgroupadd} ${db2InstanceGroup}
checkUserGroupStatus ${?} "Unable to create" ${db2InstanceGroup} "ADD"
${sysgroupadd} ${db2FencedGroup}
checkUserGroupStatus ${?} "Unable to create" ${db2FencedGroup} "ADD"
${sysgroupadd} ${db2DASGroup}
checkUserGroupStatus ${?} "Unable to create" ${db2DASGroup} "ADD"
log "I Creating DB2 users..."
${sysuseradd} -g ${db2InstanceGroup} ${db2InstanceUser}
checkUserGroupStatus ${?} "Unable to create" ${db2InstanceUser} "ADD"
${echo} "${db2InstanceUser}:${defaultPwd}" | ${chpasswd}
${sysuseradd} -g ${db2FencedGroup} ${db2FencedUser}
checkUserGroupStatus ${?} "Unable to create" ${db2FencedUser} "ADD"
${echo} "${db2FencedUser}:${defaultPwd}" | ${chpasswd}
${sysuseradd} -g ${db2DASGroup} ${db2DASUser}
checkUserGroupStatus ${?} "Unable to create" ${db2DASUser} "ADD"
${echo} "${db2DASUser}:${defaultPwd}" | ${chpasswd}
${sysuseradd} -g ${db2InstanceGroup} lcuser
checkUserGroupStatus ${?} "Unable to create" "lcuser" "ADD"
${echo} "lcuser:${defaultPwd}" | ${chpasswd}

# Increase open file limit for instance owner group
log "I Setting open file limits for ${db2InstanceGroup} in ${limitsFile}..."
${grep} ${db2InstanceGroup} ${limitsFile}
status=${?}
if [ ${status} -ne 0 ]; then
	${printf} "@${db2InstanceGroup}${limitFilesSoft}" >> ${limitsFile}
	${printf} "@${db2InstanceGroup}${limitFilesHard}" >> ${limitsFile}
else
	log "W Limits already set for ${db2InstanceGroup} in ${limitsFile}. Manual review required."
fi 

# Update the pam.d files
log "I Updating /etc/pam.d files..."
updatePamFiles

# Build the response file
log "I Building the DB2 silent install file..."
${printf} "PROD = DB2_SERVER_EDITION\n" >> ${db2InstallResponseFile}
${printf} "FILE = ${db2InstallDir}\n" >> ${db2InstallResponseFile}
${printf} "LIC_AGREEMENT = ACCEPT\n" >> ${db2InstallResponseFile}
${printf} "INSTALL_TYPE = TYPICAL\n" >> ${db2InstallResponseFile}
${printf} "INSTANCE = DB2_INST\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.NAME = ${db2InstanceName}\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.GROUP_NAME = ${db2InstanceGroup}\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.HOME_DIRECTORY = /home/${db2InstanceUser}\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.PASSWORD = ${defaultPwd}\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.AUTOSTART = YES\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.START_DURING_INSTALL = YES\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.FENCED_USERNAME = ${db2FencedUser}\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.FENCED_GROUP_NAME = ${db2FencedGroup}\n" >> ${db2InstallResponseFile}

# Install DB2
log "I Performing DB2 install..."
${db2Install} ${db2InstallResponseFile}
checkStatus ${?} "E DB2 installation failed. Exiting."

# Validate the install
log "I Validating DB2 install..."
${db2Val} -a -l ${db2ValidationLog}
${grep} ${db2FilesValidated} ${db2ValidationLog}
checkStatus ${?} "E DB2 validation failed. Review ${db2ValidationLog} for details."
${grep} ${db2InstanceValidated} ${db2ValidationLog}
checkStatus ${?} "E DB2 validation failed. Review ${db2ValidationLog} for details."

# Apply the DB2 license
log "I Applying DB2 license..."
${db2Licm} -a ${db2LicenseFile}
checkStatus ${?} "E DB2 license installation failed."

# Enable Unicode
log "I Enabling Unicode codepage..."
${su} - ${db2InstanceUser} -c "${db2SetCodepage} >/dev/null 2>&1"; result=${?}
if [ ${result} -ne 0 ]; then
    log "W Unable to set DB2 codepage. Manual configuration required." 
fi
${su} - ${db2InstanceUser} -c "${db2Stop} >/dev/null 2>&1"; result=${?}
if [ ${result} -ne 0 ]; then
    log "W Unable to stop DB2 after setting codepage. Manual restart required." 
fi
${su} - ${db2InstanceUser} -c "${db2Start} >/dev/null 2>&1"; result=${?}
if [ ${result} -ne 0 ]; then
    log "W Unable to start DB2 after setting codepage. Manual restart required." 
fi

logInstall DB2 end 
