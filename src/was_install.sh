#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

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
installPackages="${iimInstallDir}/eclipse/tools/imcl -log ${wasInstallLog} -acceptLicense input"
getWasVersion="${wasInstallDir}/bin/versionInfo.sh"
getIhsVersion="${ihsInstallDir}/bin/httpd -v"
getPluginsVersion="${pluginsInstallDir}/bin/versionInfo.sh"
getWctVersion="${wctInstallDir}/bin/versionInfo.sh"

# Response files
wasResponseFileTemplate="${stagingDir}/responsefiles/was_install.template"
wasInstallResponseFile="${stagingDir}/${wasStagingDir}/was_install.xml"

# Make sure script is running as root
checkForRoot

# Clean up from prior run of install script
${rm} -f -r ${stagingDir}/${wasStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to remove ${stagingDir}/${wasStagingDir}. Exiting."
${mkdir} ${stagingDir}/${wasStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to create ${stagingDir}/${wasStagingDir}. Exiting."
cd ${stagingDir}/${wasStagingDir}

# First see if IIM is installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} == 1 ]; then
    log "IIM does not appear to be installed. Exiting."
    exit 1
fi

# Download the WAS installation files
log "Downloading ${wasBasePackage_1} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBasePackage_1} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasBasePackage_2} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBasePackage_2} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasBasePackage_3} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBasePackage_3} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasBaseSupplPackage_1} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBaseSupplPackage_1} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasBaseSupplPackage_2} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBaseSupplPackage_2} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasBaseSupplPackage_3} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasBaseSupplPackage_3} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackPackage_1} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackPackage_1} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackPackage_2} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackPackage_2} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackSupplPackage_1} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackSupplPackage_1} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackSupplPackage_2} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackSupplPackage_2} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackWCTPackage_1} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackWCTPackage_1} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."
log "Downloading ${wasFixPackWCTPackage_2} from ${ftpServer}..."
${curl} ftp://${ftpServer}/${wasStagingDir}/${wasFixPackWCTPackage_2} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Download failed. Exiting."

# Unpack the downloaded files
log "Unpacking ${wasBasePackage_1}..."
${unzip} -qq ${wasBasePackage_1} -d ${wasBaseStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasBasePackage_2}..."
${unzip} -qq ${wasBasePackage_2} -d ${wasBaseStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasBasePackage_3}..."
${unzip} -qq ${wasBasePackage_3} -d ${wasBaseStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasBaseSupplPackage_1}..."
${unzip} -qq ${wasBaseSupplPackage_1} -d ${wasBaseSupplStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasBaseSupplPackage_2}..."
${unzip} -qq ${wasBaseSupplPackage_2} -d ${wasBaseSupplStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasBaseSupplPackage_3}..."
${unzip} -qq ${wasBaseSupplPackage_3} -d ${wasBaseSupplStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackPackage_1}..."
${unzip} -qq ${wasFixPackPackage_1} -d ${wasFixPackStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackPackage_2}..."
${unzip} -qq ${wasFixPackPackage_2} -d ${wasFixPackStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackSupplPackage_1}..."
${unzip} -qq ${wasFixPackSupplPackage_1} -d ${wasFixPackSupplStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackSupplPackage_2}..."
${unzip} -qq ${wasFixPackSupplPackage_2} -d ${wasFixPackSupplStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackWCTPackage_1}..."
${unzip} -qq ${wasFixPackWCTPackage_1} -d ${wasFixPackWCTStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."
log "Unpacking ${wasFixPackWCTPackage_2}..."
${unzip} -qq ${wasFixPackWCTPackage_2} -d ${wasFixPackWCTStagingDir} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unpack operation failed. Exiting."

# Extract the component ID and version info
log "Extracting package IDs and version information from repositories..."
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
log "Building WebSphere silent install response file..."
${cp} ${wasResponseFileTemplate} ${wasInstallResponseFile}
checkStatus ${?} "ERROR: Unable to copy ${wasResponseFileTemplate} to $wasInstallResponseFile}. Exiting."
${sed} -i "s|WAS_BASE|'${wasBaseRepo}'|" ${wasInstallResponseFile}
${sed} -i "s|WAS_SUPPL_BASE|'${wasBaseSupplRepo}'|" ${wasInstallResponseFile}
${sed} -i "s|WAS_FP|'${wasFixPackRepo}'|" ${wasInstallResponseFile}
${sed} -i "s|WAS_SUPPL_FP|'${wasFixPackSupplRepo}'|" ${wasInstallResponseFile}
${sed} -i "s|WAS_WCT_FP|'${wasFixPackWCTRepo}'|" ${wasInstallResponseFile}
${sed} -i "s|IM_SHARED|'${iimSharedDataDir}'|" ${wasInstallResponseFile}
${sed} -i "s|WAS_INSTALL_DIR|'${wasInstallDir}'|" ${wasInstallResponseFile}
${sed} -i "s|WAS_ID|'${wasId}'|" ${wasInstallResponseFile}
${sed} -i "s|WAS_VERSION|'${wasVersion}'|" ${wasInstallResponseFile}
${sed} -i "s|IHS_INSTALL_DIR|'${ihsInstallDir}'|" ${wasInstallResponseFile}
${sed} -i "s|IHS_ID|'${ihsId}'|" ${wasInstallResponseFile}
${sed} -i "s|IHS_VERSION|'${ihsVersion}'|" ${wasInstallResponseFile}
${sed} -i "s|PLUGINS_INSTALL_DIR|'${pluginsInstallDir}'|" ${wasInstallResponseFile}
${sed} -i "s|PLUGINS_ID|'${pluginsId}'|" ${wasInstallResponseFile}
${sed} -i "s|PLUGINS_VERSION|'${pluginsVersion}'|" ${wasInstallResponseFile}
${sed} -i "s|WCT_INSTALL_DIR|'${wctInstallDir}'|" ${wasInstallResponseFile}
${sed} -i "s|WCT_ID|'${wctId}'|" ${wasInstallResponseFile}
${sed} -i "s|WCT_VERSION|'${wctVersion}'|" ${wasInstallResponseFile}

# Install the packages
log "Installing WebSphere packages..."
${installPackages} ${wasInstallResponseFile} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Installation of WAS components failed. Review ${wasInstallLog} for details."

# Updated shared libraries
log "Adding IHS shared libraries to ${sysSharedLibDir}"
${sh} -c "${echo} ${ihsInstallDir}/lib > ${sysSharedLibDir}/httpd-lib.conf"
checkStatus ${?} "ERROR: Unable to add IHS shared libraries to ${sysSharedLibDir}"
${ldconfig}

# Print the results
log "SUCCESS! All WebSphere packages were installed. Printing version info..."
log "WebSphere Application Server version:\n"
${getWasVersion}
log "WebSphere Plugins version:\n"
${getPluginsVersion}
log "WebSphere Toolbox version:\n"
${getWctVersion}
log "IBM HTTP Server version:\n"
${getIhsVersion}
log "\n"
