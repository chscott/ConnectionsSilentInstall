#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
wasInstallLog="${logDir}/was_install.log"
wasBaseRepo=${stagingDir}/${wasStagingDir}/${wasBaseStagingDir}
wasBaseSupplRepo=${stagingDir}/${wasStagingDir}/${wasBaseSupplStagingDir}
wasFixPackRepo=${stagingDir}/${wasStagingDir}/${wasFixPackStagingDir}
wasFixPackSupplRepo=${stagingDir}/${wasStagingDir}/${wasFixPackSupplStagingDir}
wasFixPackWCTRepo=${stagingDir}/${wasStagingDir}/${wasFixPackWCTStagingDir}
listAvailablePackages="${iimInstallDir}/eclipse/tools/imcl listAvailablePackages -repositories"
installPackages="${iimInstallDir}/eclipse/tools/imcl -log ${wasInstallLog} -acceptLicense input"
getWasVersion="${wasInstallDir}/bin/versionInfo.sh"
getIhsVersion="${ihsInstallDir}/bin/httpd -v"
getPlgVersion="${plgInstallDir}/bin/versionInfo.sh"
getWctVersion="${wctInstallDir}/bin/versionInfo.sh"
wasResponseFileTemplate="${stagingDir}/responsefiles/was_install.template"
wasInstallResponseFile="${stagingDir}/${wasStagingDir}/was_install.xml"

# Do initialization stuff
init was install

# First see if IIM is installed
result=$(isInstalled ${iimInstallDir})
if [ ${result} == 1 ]; then
    log "IIM does not appear to be installed. Exiting."
    exit 1
fi

# Download the WAS installation files
downloadFile was "${wasBasePackage_1}"
downloadFile was "${wasBasePackage_2}"
downloadFile was "${wasBasePackage_3}"
downloadFile was "${wasBaseSupplPackage_1}"
downloadFile was "${wasBaseSupplPackage_2}"
downloadFile was "${wasBaseSupplPackage_3}"
downloadFile was "${wasFixPackPackage_1}"
downloadFile was "${wasFixPackPackage_2}"
downloadFile was "${wasFixPackSupplPackage_1}"
downloadFile was "${wasFixPackSupplPackage_2}"
downloadFile was "${wasFixPackWCTPackage_1}"
downloadFile was "${wasFixPackWCTPackage_2}"

# Unpack the downloaded files
unpackFileToDirectory zip "${wasBasePackage_1}" "${wasBaseStagingDir}"
unpackFileToDirectory zip "${wasBasePackage_2}" "${wasBaseStagingDir}"
unpackFileToDirectory zip "${wasBasePackage_3}" "${wasBaseStagingDir}"
unpackFileToDirectory zip "${wasBaseSupplPackage_1}" "${wasBaseSupplStagingDir}"
unpackFileToDirectory zip "${wasBaseSupplPackage_2}" "${wasBaseSupplStagingDir}"
unpackFileToDirectory zip "${wasBaseSupplPackage_3}" "${wasBaseSupplStagingDir}"
unpackFileToDirectory zip "${wasFixPackPackage_1}" "${wasFixPackStagingDir}"
unpackFileToDirectory zip "${wasFixPackPackage_2}" "${wasFixPackStagingDir}"
unpackFileToDirectory zip "${wasFixPackSupplPackage_1}" "${wasFixPackSupplStagingDir}"
unpackFileToDirectory zip "${wasFixPackSupplPackage_2}" "${wasFixPackSupplStagingDir}"
unpackFileToDirectory zip "${wasFixPackWCTPackage_1}" "${wasFixPackWCTStagingDir}"
unpackFileToDirectory zip "${wasFixPackWCTPackage_2}" "${wasFixPackWCTStagingDir}"

# Extract the component ID and version info
log "Extracting package IDs and version information from repositories..."
wasIdVersion=$(${listAvailablePackages} "${wasBaseRepo},${wasFixPackRepo}" | ${grep} -F 'com.ibm.websphere.ND' | ${sort} | ${tail} -1)
wasId=$(echo ${wasIdVersion} | awk -F '_' '{print $1}')
wasVersion=$(echo ${wasIdVersion} | awk -F '_' '{print $2"_"$3}')
ihsIdVersion=$(${listAvailablePackages} "${wasBaseSupplRepo},${wasFixPackSupplRepo}" | ${grep} -F 'com.ibm.websphere.IHS' | ${sort} | ${tail} -1)
ihsId=$(echo ${ihsIdVersion} | awk -F '_' '{print $1}')
ihsVersion=$(echo ${ihsIdVersion} | awk -F '_' '{print $2"_"$3}')
plgIdVersion=$(${listAvailablePackages} "${wasBaseSupplRepo},${wasFixPackSupplRepo}" | ${grep} -F 'com.ibm.websphere.PLG' | ${sort} | ${tail} -1)
plgId=$(echo ${plgIdVersion} | awk -F '_' '{print $1}')
plgVersion=$(echo ${plgIdVersion} | awk -F '_' '{print $2"_"$3}')
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
${sed} -i "s|PLUGINS_INSTALL_DIR|'${plgInstallDir}'|" ${wasInstallResponseFile}
${sed} -i "s|PLUGINS_ID|'${plgId}'|" ${wasInstallResponseFile}
${sed} -i "s|PLUGINS_VERSION|'${plgVersion}'|" ${wasInstallResponseFile}
${sed} -i "s|WCT_INSTALL_DIR|'${wctInstallDir}'|" ${wasInstallResponseFile}
${sed} -i "s|WCT_ID|'${wctId}'|" ${wasInstallResponseFile}
${sed} -i "s|WCT_VERSION|'${wctVersion}'|" ${wasInstallResponseFile}

# Install the packages
log "Installing WebSphere packages..."
${installPackages} ${wasInstallResponseFile} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Installation of WAS components failed. Review ${wasInstallLog} for details."

# Update shared libraries
log "Adding IHS shared libraries to ${sysSharedLibDir}"
${sh} -c "${echo} ${ihsInstallDir}/lib > ${sysSharedLibDir}/httpd-lib.conf"
checkStatus ${?} "ERROR: Unable to add IHS shared libraries to ${sysSharedLibDir}"
${ldconfig}

# Print the results
log "SUCCESS! All WebSphere packages were installed. Printing version info..."
wasVersion=$(${getWasVersion} | ${grep} "^Version  " | ${tr} -s ' ' | ${cut} -d ' ' -f 2)
plgVersion=$(${getPlgVersion} | ${grep} "^Version  " | ${tr} -s ' ' | ${cut} -d ' ' -f 2)
wctVersion=$(${getWctVersion} | ${grep} "^Version  " | ${tr} -s ' ' | ${cut} -d ' ' -f 2)
ihsVersion=$(${getIhsVersion} | ${grep} "version" | ${cut} -d '/' -f 2 | ${cut} -d ' ' -f 1)
log "WebSphere Application Server version: ${wasVersion}"
log "WebSphere Plugins version: ${plgVersion}"
log "WebSphere Toolbox version: ${wctVersion}"
log "IBM HTTP Server version: ${ihsVersion}"
