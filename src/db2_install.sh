#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Logs
db2PrereqReport="${stagingDir}/${db2StagingDir}/db2prereqs.rpt"
db2SAMPrereqReport="${stagingDir}/${db2StagingDir}/db2SAMprereqs.rpt"
db2InstallLog="${stagingDir}/${db2StagingDir}/db2_install.log"
db2InstallTrace="${stagingDir}/${db2StagingDir}/db2_install.trc"
db2ValidationLog="${stagingDir}/${db2StagingDir}/db2val.log"

# Commands
db2Prereq="${db2StagingSubDir}/db2prereqcheck -i -v 11.1.1.1 -o ${db2PrereqReport}"
db2SAMPrereq="${db2StagingSubDir}/db2/linuxamd64/tsamp/prereqSAM -l ${db2SAMPrereqReport}"
db2Setup="${db2StagingSubDir}/db2setup -l ${db2InstallLog} -t ${db2InstallTrace} -r"
db2Licm="${db2InstallDir}/adm/db2licm"
db2Val="${db2InstallDir}/bin/db2val"
db2InstallResponseFile="db2_install.rsp"
db2LicenseFile="aese_u/db2/license/db2aese_u.lic"
db2Level="${db2InstallDir}/bin/db2level"

# Status codes
db2PrereqSuccess="DBT3533I"
db2FilesValidated="DBI1335I"
db2InstanceValidated="DBI1339I"

# Make sure script is running as root
checkForRoot

# Clean up from prior run of install script
${rm} -f -r ${stagingDir}/${db2StagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to remove ${stagingDir}/${db2StagingDir}. Exiting."
${mkdir} ${stagingDir}/${db2StagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to create ${stagingDir}/${db2StagingDir}. Exiting."
cd ${stagingDir}/${db2StagingDir}

# Download the DB2 installation file
log "Downloading ${db2InstallPackage} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${db2StagingDir}/${db2InstallPackage} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."

# Download the DB2 license file
log "Downloading ${db2LicensePackage} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${db2StagingDir}/${db2LicensePackage} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."

# Unpack the downloaded files
log "Unpacking ${db2InstallPackage}..."
${tar} -zxf ${db2InstallPackage} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${db2LicensePackage}..."
${unzip} -qq ${db2LicensePackage} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."

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
${echo} "${db2InstanceUser}:${defaultPwd}" | ${chpasswd} >>${scriptLog} 2>&1
${sysuseradd} -g ${db2FencedGroup} ${db2FencedUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2FencedUser} "ADD"
${echo} "${db2FencedUser}:${defaultPwd}" | ${chpasswd} >>${scriptLog} 2>&1
${sysuseradd} -g ${db2DASGroup} ${db2DASUser} >>${scriptLog} 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2DASUser} "ADD"
${echo} "${db2DASUser}:${defaultPwd}" | ${chpasswd} >>${scriptLog} 2>&1

# Increase open file limit for instance owner group
${grep} ${db2InstanceGroup} ${limitsFile} >>${scriptLog} 2>&1
status=${?}
if [ ${status} -ne 0 ]; then
	${printf} "@${db2InstanceGroup}${limitFilesSoft}" >> ${limitsFile}
	${printf} "@${db2InstanceGroup}${limitFilesHard}" >> ${limitsFile}
else
	log "WARNING: limits already set for ${db2InstanceGroup} in ${limitsFile}. Manual review recommended."
fi 

# Update the pam.d files
updatePamFiles

# Build the silent install file
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
${db2Setup} ${db2InstallResponseFile} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: DB2 installation failed. Review ${db2InstallLog} and ${db2InstallTrace} for details."

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

# Print the results
log "SUCCESS! DB2 has been installed. Printing db2level info...\n"
${db2Level}
