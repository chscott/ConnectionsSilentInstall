#!/bin/bash

# Source prereq scripts
. src/utils.sh
. src/vars.sh

testForRoot

# Logs
wasInstallLog="${stagingDir}/${wasStagingDir}/was_install.log"

# Repos
wasBaseRepo=${stagingDir}/${wasStagingDir}/${wasBaseStagingDir}
wasBaseSupplRepo=${stagingDir}/${wasStagingDir}/${wasBaseSupplStagingDir}
wasFixPackRepo=${stagingDir}/${wasStagingDir}/${wasFixPackStagingDir}
wasFixPackSupplRepo=${stagingDir}/${wasStagingDir}/${wasFixPackSupplStagingDir}
wasFixPackWCTRepo=${stagingDir}/${wasStagingDir}/${wasFixPackWCTStagingDir}

# Commands
listAvailablePackages="${iimInstallDir}/eclipse/tools/imcl listAvailablePackages -repositories"

# Response files
wasResponseFileTemplate="${stagingDir}/responsefiles/was_install.xml.template"
wasResponseFile="${stagingDir}/${wasStagingDir}/was_install.xml"

# Clean up from prior run of install script
${rm} -f -r ${stagingDir}/${wasStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unable to remove ${stagingDir}/${wasStagingDir}. Exiting."
${mkdir} ${stagingDir}/${wasStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unable to create ${stagingDir}/${wasStagingDir}. Exiting."
cd ${stagingDir}/${wasStagingDir}

# Download the WAS installation files
log "Downloading ${wasBasePackage_1} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBasePackage_1} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasBasePackage_2} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBasePackage_2} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasBasePackage_3} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBasePackage_3} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasBaseSupplPackage_1} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBaseSupplPackage_1} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasBaseSupplPackage_2} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBaseSupplPackage_2} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasBaseSupplPackage_3} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBaseSupplPackage_3} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackPackage_1} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackPackage_1} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackPackage_2} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackPackage_2} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackSupplPackage_1} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackSupplPackage_1} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackSupplPackage_2} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackSupplPackage_2} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackWCTPackage_1} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackWCTPackage_1} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackWCTPackage_2} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackWCTPackage_2} >/dev/null 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."

# Unpack the downloaded files
log "Unpacking ${wasBasePackage_1}..."
${unzip} -qq ${wasBasePackage_1} -d ${wasBaseStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasBasePackage_2}..."
${unzip} -qq ${wasBasePackage_2} -d ${wasBaseStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasBasePackage_3}..."
${unzip} -qq ${wasBasePackage_3} -d ${wasBaseStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasBaseSupplPackage_1}..."
${unzip} -qq ${wasBaseSupplPackage_1} -d ${wasBaseSupplStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasBaseSupplPackage_2}..."
${unzip} -qq ${wasBaseSupplPackage_2} -d ${wasBaseSupplStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasBaseSupplPackage_3}..."
${unzip} -qq ${wasBaseSupplPackage_3} -d ${wasBaseSupplStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackPackage_1}..."
${unzip} -qq ${wasFixPackPackage_1} -d ${wasFixPackStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackPackage_2}..."
${unzip} -qq ${wasFixPackPackage_2} -d ${wasFixPackStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackSupplPackage_1}..."
${unzip} -qq ${wasFixPackSupplPackage_1} -d ${wasFixPackSupplStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackSupplPackage_2}..."
${unzip} -qq ${wasFixPackSupplPackage_2} -d ${wasFixPackSupplStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackWCTPackage_1}..."
${unzip} -qq ${wasFixPackWCTPackage_1} -d ${wasFixPackWCTStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackWCTPackage_2}..."
${unzip} -qq ${wasFixPackWCTPackage_2} -d ${wasFixPackWCTStagingDir} >/dev/null 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."

# Extract the component ID and version info
log "Building WAS silent install response file..."
wasIdVersion=$(${listAvailablePackages} "${wasBaseRepo},${wasFixPackRepo}" | ${grep} -F 'com.ibm.websphere.ND' | ${sort} | ${tail} -1)
wasId=$(echo ${wasIdVersion} | awk -F '_' '{print $1}')
wasVersion=$(echo ${wasIdVersion} | awk -F '_' '{print $2"_"$3}')
ihsIdVersion=$(${listAvailablePackages} "${wasBaseSupplRepo},${wasFixPackSupplRepo}" | ${grep} -F 'com.ibm.websphere.IHS' | ${sort} | ${tail} -1)
ihsId=$(echo ${ihsIdVersion} | awk -F '_' '{print $1}')
ihsVersion=$(echo ${ihsIdVersion} | awk -F '_' '{print $2"_"$3}')
pluginsIdVersion=$(${listAvailablePackages} "${wasBaseSupplRepo},${wasFixPackSupplRepo}" | ${grep} -F 'com.ibm.websphere.PLG' | ${sort} | ${tail} -1)
pluginsId=$(echo ${pluginsIdVersion} | awk -F '_' '{print $1}')
pluginsVersion=$(echo ${pluginsIdVersion} | awk -F '_' '{print $2"_"$3}')
wctIdVersion=$(${listAvailablePackages} "${wasBaseSupplRepo},${wasFixPackWCTRepo}" | ${grep} -F 'com.ibm.websphere.WCT' | ${sort} | ${tail} -1)
wctId=$(echo ${wctIdVersion} | awk -F '_' '{print $1}')
wctVersion=$(echo ${wctIdVersion} | awk -F '_' '{print $2"_"$3}')

# Build the response file
${cp} ${wasResponseFileTemplate} ${wasResponseFile}
${sed} -i "s|WAS_BASE|'${wasBaseRepo}'|" ${wasResponseFile}
${sed} -i "s|WAS_SUPPL_BASE|'${wasBaseSupplRepo}'|" ${wasResponseFile}
${sed} -i "s|WAS_FP|'${wasFixPackRepo}'|" ${wasResponseFile}
${sed} -i "s|WAS_SUPPL_FP|'${wasFixPackSupplRepo}'|" ${wasResponseFile}
${sed} -i "s|WAS_WCT_FP|'${wasFixPackWCTRepo}'|" ${wasResponseFile}
${sed} -i "s|IM_SHARED|'${iimSharedDataDir}'|" ${wasResponseFile}
${sed} -i "s|WAS_INSTALL_DIR|'${wasInstallDir}'|" ${wasResponseFile}
${sed} -i "s|WAS_ID|'${wasId}'|" ${wasResponseFile}
${sed} -i "s|WAS_VERSION|'${wasVersion}'|" ${wasResponseFile}
${sed} -i "s|IHS_INSTALL_DIR|'${ihsInstallDir}'|" ${wasResponseFile}
${sed} -i "s|IHS_ID|'${ihsId}'|" ${wasResponseFile}
${sed} -i "s|IHS_VERSION|'${ihsVersion}'|" ${wasResponseFile}
${sed} -i "s|PLUGINS_INSTALL_DIR|'${pluginsInstallDir}'|" ${wasResponseFile}
${sed} -i "s|PLUGINS_ID|'${pluginsId}'|" ${wasResponseFile}
${sed} -i "s|PLUGINS_VERSION|'${pluginsVersion}'|" ${wasResponseFile}
${sed} -i "s|WCT_INSTALL_DIR|'${wctInstallDir}'|" ${wasResponseFile}
${sed} -i "s|WCT_ID|'${wctId}'|" ${wasResponseFile}
${sed} -i "s|WCT_VERSION|'${wctVersion}'|" ${wasResponseFile}
