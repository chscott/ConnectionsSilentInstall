#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/tdi/tdi.conf

# Do initialization stuff
init ${tdiStagingDir} install

logInstall TDI begin

# Download and unpack the install files 
log "I Downloading TDI install files..."
{ ${downloadFile} ${ftpServer} ${ftpTDIDir} ${tdiBasePackage}; ${echo} ${?} >${childProcessTempDir}/${tdiStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpTDIDir} ${tdiFixPackPackage}; ${echo} ${?} >${childProcessTempDir}/${tdiStagingDir}/${BASHPID}; } &
# See if we have a tdisol fix available. If so, grab that instead of the GA one.
if [ ! -z ${tdisolFixPackage} ]; then
    { ${downloadFile} ${ftpServer} ${ftpConnectionsDir} ${tdisolFixPackage}; ${echo} ${?} >${childProcessTempDir}/${tdiStagingDir}/${BASHPID}; } &
else
    { ${downloadFile} ${ftpServer} ${ftpConnectionsDir} ${icInstallPackage}; ${echo} ${?} >${childProcessTempDir}/${tdiStagingDir}/${BASHPID}; } &
fi
wait
checkChildProcessStatus ${childProcessTempDir}/${tdiStagingDir}
resetChildProcessTempDir ${childProcessTempDir}/${tdiStagingDir}
unpackFile tar ${tdiBasePackage}
unpackFile zip ${tdiFixPackPackage}

# Build the response file
copyTemplate ${tdiResponseFileTemplate} ${tdiInstallResponseFile}
${sed} -i "s|TDI_INSTALL_DIR|${tdiInstallDir}|" ${tdiInstallResponseFile}

# Install TDI Base
log "I Performing TDI install..."
tdiInstallBin=$(ls "${stagingDir}/${tdiStagingDir}/linux_x86_64")
tdiInstall="${stagingDir}/${tdiStagingDir}/linux_x86_64/${tdiInstallBin}"
${tdiInstall} -f ${tdiInstallResponseFile} -i silent -D\$TDI_NOSHORTCUTS\$="true"
checkStatus ${?} "E TDI installation failed. Exiting."

# Install TDI Fix Pack
log "I Performing TDI fix pack install..."
${cp} -f ${updateInstaller} ${tdiInstallDir}/maintenance 
checkStatus ${?} "E Unable to copy ${updateInstaller} to ${tdiInstallDir}/maintenance. Exiting."
${tdiInstallDir}/bin/applyUpdates.sh -update ${fixPack}
checkStatus ${?} "E TDI fix pack installation failed. Exiting."

# Copy the database JAR files
log "I Copying DB2 JAR files to TDI..."
${cp} -f ${db2JarDir}/db2jcc.jar ${tdiJarDir}
checkStatus ${?} "W Unable to copy ${db2JarDir}/db2jcc.jar to ${tdiJarDir}. Manual update required."
${cp} -f ${db2JarDir}/db2jcc_license_cu.jar ${tdiJarDir}
checkStatus ${?} "W Unable to copy ${db2JarDir}/db2jcc_license_cu.jar to ${tdiJarDir}. Manual update required."

# Update ibmdisrv Java heap size
log "I Updating Java heap size for ibmdisrv..." 
${sed} -i 's|\(\"$TDI_JAVA_PROGRAM\"\)|\1 -Xms1024M -Xmx2048M|' ${tdiInstallDir}/ibmdisrv
checkStatus ${?} "W Unable to update Java heap size for ibmdisrv. Manual update required."

# Copy tdisol to the TDI installation directory
${mkdir} -p ${tdiInstallDir}/tdisol
checkStatus ${?} "E Unable to create ${tdiInstallDir}/tdisol directory. Exiting."
if [ ! -z ${tdisolFixPackage} ]; then
    unpackFileToDirectory tar ${tdisolFixPackage} ${tdiInstallDir}/tdisol
else
    unpackFile tar ${icInstallPackage}
    unpackFileToDirectory tar ${tdisol} ${tdiInstallDir}/tdisol
fi
checkStatus ${?} "E Unable to copy solution directory to ${tdiInstallDir}/tdisol. Exiting."

# Update tdienv.sh with the correct path
${sed} -i "s|\(TDIPATH=\).*|\1${tdiInstallDir}|" ${tdiInstallDir}/tdisol/tdienv.sh
checkStatus ${?} "W Unable to update tdievn.sh. Manual update required."

# Make the executables in tdisol executable
${chmod} -R u+x ${tdiInstallDir}/tdisol/*.sh
checkStatus ${?} "E Unable to make tdisol scripts executable. Exiting."
${chmod} u+x ${tdiInstallDir}/tdisol/netstore
checkStatus ${?} "E Unable to make tdisol scripts executable. Exiting."

logInstall TDI end
