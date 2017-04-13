#!/bin/bash

. src/utils.sh

# Directories
db2StagingDir="db2"
db2StagingSubDir="server_t"
db2InstallDir="/opt/ibm/db2"

# Logs
db2PrereqReport="${stagingDir}/${db2StagingDir}/db2prereqs.rpt"
db2SAMPrereqReport="${stagingDir}/${db2StagingDir}/db2SAMprereqs.rpt"
db2InstallLog="${stagingDir}/${db2StagingDir}/db2setup.log"
db2TraceLog="${stagingDir}/${db2StagingDir}/db2setup.trc"
db2ValidationLog="${stagingDir}/${db2StagingDir}/db2val.log"

# Commands
db2Prereq="${db2StagingSubDir}/db2prereqcheck -i -v 11.1.1.1 -o ${db2PrereqReport}"
db2SAMPrereq="${db2StagingSubDir}/db2/linuxamd64/tsamp/prereqSAM -l ${db2SAMPrereqReport}"
db2Setup="${db2StagingSubDir}/db2setup -l ${db2InstallLog} -t ${db2TraceLog} -r"
db2Licm="${db2InstallDir}/adm/db2licm"
db2Val="${db2InstallDir}/bin/db2val"
db2InstallResponseFile="db2_install.rsp"
db2LicenseFile="aese_u/db2/license/db2aese_u.lic"
db2Level="${db2InstallDir}/bin/db2level"

# Status codes
db2PrereqSuccess="DBT3533I"
db2FilesValidated="DBI1335I"
db2InstanceValidated="DBI1339I"

# FTP
ftpServer="cs-ftp.swg.usma.ibm.com"
db2InstallPackage="v11.1.1fp1_linuxx64_server_t.tar.gz"
db2LicensePackage="DB2_AESE_AUSI_Activation_11.1.zip"

# Users and groups
db2InstanceGroup="db2iadm1"
db2FencedGroup="db2fsdm1"
db2DASGroup="dasadm1"
db2InstanceUser="db2inst1"
db2FencedUser="db2fenc1"
db2DASUser="dasusr1"

testForRoot

${rm} -f -r ${stagingDir}/${db2StagingDir}
checkStatus ${?} "ERROR: Unable to remove ${stagingDir}/${db2StagingDir}. Exiting."
${mkdir} ${stagingDir}/${db2StagingDir}
checkStatus ${?} "ERROR: Unable to create ${stagingDir}/${db2StagingDir}. Exiting."
cd ${stagingDir}/${db2StagingDir}

# Download the DB2 installation file
log "Downloading ${db2InstallPackage} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${db2StagingDir}/${db2InstallPackage}
checkStatus ${?} "ERROR: Download failed. Exiting."

# Download the DB2 license file
log "Downloading ${db2LicensePackage} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${db2StagingDir}/${db2LicensePackage}
checkStatus ${?} "ERROR: Download failed. Exiting."

# Unpack the downloaded files
log "Unpacking ${db2InstallPackage}..."
${tar} -zxf ${db2InstallPackage} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${db2LicensePackage}..."
${unzip} -qq ${db2LicensePackage} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."

# Check DB2 prereqs
log "Checking DB2 prerequisites..."
${db2Prereq} >/dev/null 2>&1
${grep} ${db2PrereqSuccess} ${db2PrereqReport} >/dev/null 2>&1 
checkStatus ${?} "ERROR: DB2 prereq check failed. Review ${db2PrereqReport} and address any reported issues before proceeding."
${db2SAMPrereq} >/dev/null 2>&1
checkStatus ${?} "ERROR: DB2 SAM prereq check failed. Review ${db2SAMPrereqReport} and address any reported issues before proceeding."
log "All prerequisites are in place. Continuing..."

# Add required groups
log "Creating DB2 groups..."
${sysgroupadd} ${db2InstanceGroup} >/dev/null 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2InstanceGroup}
${sysgroupadd} ${db2FencedGroup} >/dev/null 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2FencedGroup}
${sysgroupadd} ${db2DASGroup} >/dev/null 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2DASGroup}

# Add required users
log "Creating DB2 users..."
${sysuseradd} -g ${db2InstanceGroup} ${db2InstanceUser} >/dev/null 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2InstanceUser}
${echo} "${db2InstanceUser}:${defaultPwd}" | ${chpasswd} >/dev/null 2>&1
${sysuseradd} -g ${db2FencedGroup} ${db2FencedUser} >/dev/null 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2FencedUser}
${echo} "${db2FencedUser}:${defaultPwd}" | ${chpasswd} >/dev/null 2>&1
${sysuseradd} -g ${db2DASGroup} ${db2DASUser} >/dev/null 2>&1
checkUserGroupStatus ${?} "Unable to create" ${db2DASUser}
${echo} "${db2DASUser}:${defaultPwd}" | ${chpasswd} >/dev/null 2>&1

# Increase open file limit for instance owner group
${grep} ${db2InstanceGroup} ${limitsFile} >/dev/null 2>&1
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
${printf} "DB2_INST.NAME = ${db2InstanceUser}\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.GROUP_NAME = ${db2InstanceGroup}\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.HOME_DIRECTORY = /home/${db2InstanceUser}\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.PASSWORD = ${defaultPwd}\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.AUTOSTART = YES\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.START_DURING_INSTALL = YES\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.FENCED_USERNAME = ${db2FencedUser}\n" >> ${db2InstallResponseFile}
${printf} "DB2_INST.FENCED_GROUP_NAME = ${db2FencedGroup}\n" >> ${db2InstallResponseFile}

# Install DB2
log "Installing DB2..."
${db2Setup} ${db2InstallResponseFile} >/dev/null 2>&1
checkStatus ${?} "ERROR: DB2 installation failed. Review ${db2InstallLog} and ${db2TraceLog} for details."

# Validate the install
log "Validating the DB2 install..."
${db2Val} -a -l ${db2ValidationLog} >/dev/null 2>&1
${grep} ${db2FilesValidated} ${db2ValidationLog} >/dev/null 2>&1 
checkStatus ${?} "ERROR: DB2 validation failed. Review ${db2ValidationLog} for details."
${grep} ${db2InstanceValidated} ${db2ValidationLog} >/dev/null 2>&1 
checkStatus ${?} "ERROR: DB2 validation failed. Review ${db2ValidationLog} for details."

# Apply the DB2 license
log "Applying DB2 license..."
${db2Licm} -a ${db2LicenseFile} >/dev/null 2>&1
checkStatus ${?} "ERROR: DB2 license installation failed."

# Print the results
log "SUCCESS! DB2 has been installed. Printing db2level info...\n"
${db2Level}
