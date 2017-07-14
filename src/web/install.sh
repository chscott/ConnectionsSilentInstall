#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/web/web.conf

# Do initialization stuff
init ${webStagingDir} install

logInstall 'WebSphere Components' begin

# First see if IIM is installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} == 1 ]; then
    log "E: IIM does not appear to be installed. Exiting."
    exit 1
fi

# Download and unpack the install files 
log "I Downloading WebSphere install files..."
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webBasePackage_1}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webBasePackage_2}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webBasePackage_3}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webBaseSupplPackage_1}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webBaseSupplPackage_2}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webBaseSupplPackage_3}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webFixPackPackage_1}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webFixPackPackage_2}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webFixPackSupplPackage_1}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webFixPackSupplPackage_2}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webFixPackWCTPackage_1}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpWebDir} ${webFixPackWCTPackage_2}; ${echo} ${?} >${childProcessTempDir}/${webStagingDir}/${BASHPID}; } &
wait
checkChildProcessStatus ${childProcessTempDir}/${webStagingDir}
unpackFileToDirectory zip "${webBasePackage_1}" "${webBaseStagingDir}"
unpackFileToDirectory zip "${webBasePackage_2}" "${webBaseStagingDir}"
unpackFileToDirectory zip "${webBasePackage_3}" "${webBaseStagingDir}"
unpackFileToDirectory zip "${webBaseSupplPackage_1}" "${webBaseSupplStagingDir}"
unpackFileToDirectory zip "${webBaseSupplPackage_2}" "${webBaseSupplStagingDir}"
unpackFileToDirectory zip "${webBaseSupplPackage_3}" "${webBaseSupplStagingDir}"
unpackFileToDirectory zip "${webFixPackPackage_1}" "${webFixPackStagingDir}"
unpackFileToDirectory zip "${webFixPackPackage_2}" "${webFixPackStagingDir}"
unpackFileToDirectory zip "${webFixPackSupplPackage_1}" "${webFixPackSupplStagingDir}"
unpackFileToDirectory zip "${webFixPackSupplPackage_2}" "${webFixPackSupplStagingDir}"
unpackFileToDirectory zip "${webFixPackWCTPackage_1}" "${webFixPackWCTStagingDir}"
unpackFileToDirectory zip "${webFixPackWCTPackage_2}" "${webFixPackWCTStagingDir}"

# Extract the component ID and version info
log "I Extracting package IDs and version information from repositories..."
wasIdVersion=$(${imcl} listAvailablePackages -repositories "${webBaseRepo},${webFixPackRepo}" | \
             ${grep} -F 'com.ibm.websphere.ND' | ${sort} | ${tail} -1)
wasId=$(${echo} ${wasIdVersion} | awk -F '_' '{print $1}')
wasVersion=$(${echo} ${wasIdVersion} | awk -F '_' '{print $2"_"$3}')
ihsIdVersion=$(${imcl} listAvailablePackages -repositories "${webBaseSupplRepo},${webFixPackSupplRepo}" | \
             ${grep} -F 'com.ibm.websphere.IHS' | ${sort} | ${tail} -1)
ihsId=$(${echo} ${ihsIdVersion} | awk -F '_' '{print $1}')
ihsVersion=$(${echo} ${ihsIdVersion} | awk -F '_' '{print $2"_"$3}')
plgIdVersion=$(${imcl} listAvailablePackages -repositories "${webBaseSupplRepo},${webFixPackSupplRepo}" | \
             ${grep} -F 'com.ibm.websphere.PLG' | ${sort} | ${tail} -1)
plgId=$(${echo} ${plgIdVersion} | awk -F '_' '{print $1}')
plgVersion=$(${echo} ${plgIdVersion} | awk -F '_' '{print $2"_"$3}')
wctIdVersion=$(${imcl} listAvailablePackages -repositories "${webBaseSupplRepo},${webFixPackWCTRepo}" | \
             ${grep} -F 'com.ibm.websphere.WCT' | ${sort} | ${tail} -1)
wctId=$(${echo} ${wctIdVersion} | awk -F '_' '{print $1}')
wctVersion=$(${echo} ${wctIdVersion} | awk -F '_' '{print $2"_"$3}')

# Build the response file
log "I Building WebSphere silent install response file..."
${cp} -f ${webResponseFileTemplate} ${webInstallResponseFile}
checkStatus ${?} "E: Unable to copy ${webResponseFileTemplate} to ${webInstallResponseFile}. Exiting."
${sed} -i "s|WEB_BASE|'${webBaseRepo}'|" ${webInstallResponseFile}
${sed} -i "s|WEB_SUPPL_BASE|'${webBaseSupplRepo}'|" ${webInstallResponseFile}
${sed} -i "s|WEB_FP|'${webFixPackRepo}'|" ${webInstallResponseFile}
${sed} -i "s|WEB_SUPPL_FP|'${webFixPackSupplRepo}'|" ${webInstallResponseFile}
${sed} -i "s|WEB_WCT_FP|'${webFixPackWCTRepo}'|" ${webInstallResponseFile}
${sed} -i "s|IM_SHARED|'${iimSharedDataDir}'|" ${webInstallResponseFile}
${sed} -i "s|WAS_INSTALL_DIR|'${wasInstallDir}'|" ${webInstallResponseFile}
${sed} -i "s|WAS_ID|'${wasId}'|" ${webInstallResponseFile}
${sed} -i "s|WAS_VERSION|'${wasVersion}'|" ${webInstallResponseFile}
${sed} -i "s|IHS_INSTALL_DIR|'${ihsInstallDir}'|" ${webInstallResponseFile}
${sed} -i "s|IHS_ID|'${ihsId}'|" ${webInstallResponseFile}
${sed} -i "s|IHS_VERSION|'${ihsVersion}'|" ${webInstallResponseFile}
${sed} -i "s|PLUGINS_INSTALL_DIR|'${plgInstallDir}'|" ${webInstallResponseFile}
${sed} -i "s|PLUGINS_ID|'${plgId}'|" ${webInstallResponseFile}
${sed} -i "s|PLUGINS_VERSION|'${plgVersion}'|" ${webInstallResponseFile}
${sed} -i "s|WCT_INSTALL_DIR|'${wctInstallDir}'|" ${webInstallResponseFile}
${sed} -i "s|WCT_ID|'${wctId}'|" ${webInstallResponseFile}
${sed} -i "s|WCT_VERSION|'${wctVersion}'|" ${webInstallResponseFile}

# Install the packages
log "I Performing WebSphere install..."
${imcl} -log ${webInstallLog} -acceptLicense -input ${webInstallResponseFile}
checkStatus ${?} "E: Installation of WebSphere components failed. Review ${webInstallLog} for details."

# Update shared libraries
log "I Adding IHS shared libraries to ${sysSharedLibDir}..."
${sh} -c "${echo} ${ihsInstallDir}/lib > ${sysSharedLibDir}/httpd-lib.conf"
checkStatus ${?} "E: Unable to add IHS shared libraries to ${sysSharedLibDir}"
${ldconfig}

logInstall 'WebSphere Components' end
