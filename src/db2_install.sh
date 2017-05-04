#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
db2PrereqReport="${logDir}/db2prereqs.rpt"
db2SAMPrereqReport="${logDir}/db2SAMprereqs.rpt"
db2InstallLog="${logDir}/db2_install.log"
db2InstallTrace="${logDir}/db2_install.trc"
db2ValidationLog="${logDir}/db2val.log"
db2Prereq="${db2StagingSubDir}/db2prereqcheck -i -v 11.1.1.1 -o ${db2PrereqReport}"
db2SAMPrereq="${db2StagingSubDir}/db2/linuxamd64/tsamp/prereqSAM -l ${db2SAMPrereqReport}"
db2Install="${db2StagingSubDir}/db2setup -l ${db2InstallLog} -t ${db2InstallTrace} -r"
db2Licm="${db2InstallDir}/adm/db2licm"
db2Val="${db2InstallDir}/bin/db2val"
db2InstallResponseFile="db2_install.rsp"
db2LicenseFile="aese_u/db2/license/db2aese_u.lic"
db2Level="${db2InstallDir}/bin/db2level"
db2SetCodepage="/home/${db2InstanceUser}/sqllib/adm/db2set DB2CODEPAGE=1208"
db2Start="/home/${db2InstanceUser}/sqllib/adm/db2start"
db2Stop="/home/${db2InstanceUser}/sqllib/adm/db2stop"
db2PrereqSuccess="DBT3533I"
db2FilesValidated="DBI1335I"
db2InstanceValidated="DBI1339I"

# Do initialization stuff
init db2 install

# Download the install files
downloadFile db2 "${db2InstallPackage}"
downloadFile db2 "${db2LicensePackage}"

# Unpack the downloaded files
unpackFile tar "${db2InstallPackage}"
unpackFile zip "${db2LicensePackage}"

# Check DB2 prereqs
log "Checking DB2 prerequisites..."
${db2Prereq} >>${scriptLog} 2>&1
${grep} ${db2PrereqSuccess} ${db2PrereqReport} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: DB2 prereq check failed. Review ${db2PrereqReport} and address any reported issues before proceeding."
${db2SAMPrereq} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: DB2 SAM prereq check failed. Review ${db2SAMPrereqReport} and address any reported issues before proceeding."
log "All prerequisites are in place. Continuing..."

# Add required groups
log "Creating DB2 groups..."
${sysgroupadd} ${db2InstanceGroup} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2InstanceGroup} "ADD"
${sysgroupadd} ${db2FencedGroup} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2FencedGroup} "ADD"
${sysgroupadd} ${db2DASGroup} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2DASGroup} "ADD"

# Add required users
log "Creating DB2 users..."
${sysuseradd} -g ${db2InstanceGroup} ${db2InstanceUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2InstanceUser} "ADD"
${echo} "${db2InstanceUser}:${defaultPwd}" | ${chpasswd}
${sysuseradd} -g ${db2FencedGroup} ${db2FencedUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2FencedUser} "ADD"
${echo} "${db2FencedUser}:${defaultPwd}" | ${chpasswd}
${sysuseradd} -g ${db2DASGroup} ${db2DASUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2DASUser} "ADD"
${echo} "${db2DASUser}:${defaultPwd}" | ${chpasswd}
${sysuseradd} -g ${db2InstanceGroup} lcuser >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "Unable to create lcuser" "ADD"
${echo} "lcuser:${defaultPwd}" | ${chpasswd}

# Increase open file limit for instance owner group
log "Setting open file limits for ${db2InstanceGroup} in ${limitsFile}..."
${grep} ${db2InstanceGroup} ${limitsFile} >>${scriptLog} 2>&1
status=${?}
if [ ${status} -ne 0 ]; then
	${printf} "@${db2InstanceGroup}${limitFilesSoft}" >> ${limitsFile}
	${printf} "@${db2InstanceGroup}${limitFilesHard}" >> ${limitsFile}
else
	log "INFO: limits already set for ${db2InstanceGroup} in ${limitsFile}. Manual review recommended."
fi 

# Update the pam.d files
log "Updating /etc/pam.d files..."
updatePamFiles

# Build the response file
log "Building the DB2 silent install file (${db2InstallResponseFile})..."
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
log "Installing DB2..."
${db2Install} ${db2InstallResponseFile} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: DB2 installation failed. Exiting."

# Validate the install
log "Validating the DB2 install..."
${db2Val} -a -l ${db2ValidationLog} >>${scriptLog} 2>&1
${grep} ${db2FilesValidated} ${db2ValidationLog} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: DB2 validation failed. Review ${db2ValidationLog} for details."
${grep} ${db2InstanceValidated} ${db2ValidationLog} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: DB2 validation failed. Review ${db2ValidationLog} for details."

# Apply the DB2 license
log "Applying DB2 license..."
${db2Licm} -a ${db2LicenseFile} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: DB2 license installation failed."

# Enable Unicode
log "Enabling Unicode codepage..."
${su} - ${db2InstanceUser} -c "${db2SetCodepage} >/dev/null 2>&1"; result=${?}
if [ ${result} -ne 0 ]; then
    log "WARNING: Unable to set DB2 codepage. Manual configuration required." 
fi
${su} - ${db2InstanceUser} -c "${db2Stop} >/dev/null 2>&1"; result=${?}
if [ ${result} -ne 0 ]; then
    log "WARNING: Unable to stop DB2 after setting codepage. Manual restart required." 
fi
${su} - ${db2InstanceUser} -c "${db2Start} >/dev/null 2>&1"; result=${?}
if [ ${result} -ne 0 ]; then
    log "WARNING: Unable to start DB2 after setting codepage. Manual restart required." 
fi

# Print the results
version=$(${db2Level} | ${grep} tokens | ${cut} -d ' ' -f 4,5 | ${tr} -d '",\,')
log "SUCCESS! DB2 ${version} has been installed."
