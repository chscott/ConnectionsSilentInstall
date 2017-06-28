#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables 
downloadFile="../src/misc/downloadFile.sh"
icInstallLog="${logDir}/ic_install.log"
listAvailablePackages="${iimInstallDir}/eclipse/tools/imcl listAvailablePackages -repositories"
installPackages="${iimInstallDir}/eclipse/tools/imcl -log ${icInstallLog} -acceptLicense -input"
installFeature="${stagingDir}/src/ic/install_feature.sh"
encryptString="${iimInstallDir}/eclipse/tools/imcl encryptString"
icRepositoryDir="${stagingDir}/${icStagingDir}/IBM_Connections_Install/IBMConnections"
jdbcDir="${db2InstallDir}/java"
icCoreRsp="ic_install_core"
icActivitiesRsp="ic_install_activities"
icBlogsRsp="ic_install_blogs"
icBookmarksRsp="ic_install_bookmarks"
icCCMRsp="ic_install_ccm"
icCommunitiesRsp="ic_install_communities"
icForumsRsp="ic_install_forums"
icMetricsRsp="ic_install_metrics"
icMobileRsp="ic_install_mobile"
icModerationRsp="ic_install_moderation"
icProfilesRsp="ic_install_profiles"
icWikisRsp="ic_install_wikis"

# The Core response file must be first
icResponseFiles=( \
    ${icCoreRsp} \
    ${icActivitiesRsp} \
    ${icBlogsRsp} \
    ${icBookmarksRsp} \
    ${icCommunitiesRsp} \
    ${icForumsRsp} \
    ${icMetricsRsp} \
    ${icMobileRsp} \
    ${icModerationRsp} \
    ${icProfilesRsp} \
    ${icWikisRsp} \
    ${icCCMRsp}
)

log "I Beginning installation of Connections features..."

# Do initialization stuff
init ${icStagingDir} install 

# Download the install files 
log "I Downloading Connections installation files..."
{ ${downloadFile} ${ftpServer} ${ftpConnectionsDir} ${icInstallPackage}; ${echo} ${?} >${childProcessTempDir}/${icStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpCCMDir} ${ccmCEBasePackage}; ${echo} ${?} >${childProcessTempDir}/${icStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpCCMDir} ${ccmCEFixPackPackage}; ${echo} ${?} >${childProcessTempDir}/${icStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpCCMDir} ${ccmCEClientFixPackPackage}; ${echo} ${?} >${childProcessTempDir}/${icStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpCCMDir} ${ccmFNCSBasePackage}; ${echo} ${?} >${childProcessTempDir}/${icStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpCCMDir} ${ccmFNCSFixPackPackage}; ${echo} ${?} >${childProcessTempDir}/${icStagingDir}/${BASHPID}; } &

# Wait for file downloads to complete and then check status
wait
checkChildProcessStatus ${childProcessTempDir}/${icStagingDir}
resetChildProcessTempDir ${childProcessTempDir}/${icStagingDir}

# Unpack the downloaded files
unpackFile tar ${icInstallPackage}

# Extract the component ID and version info
log "I Extracting package IDs and version information from repositories..."
icRepositoryIdVersion=$(${listAvailablePackages} "${icRepositoryDir}" | ${grep} -F 'com.ibm.connections' | ${sort} | ${tail} -1)
icRepositoryId=$(${echo} ${icRepositoryIdVersion} | awk -F '_' '{print $1}')
icRepositoryVersion=$(${echo} ${icRepositoryIdVersion} | awk -F '_' '{print $2"_"$3"_"$4}')

# Generate an encrypted password
encryptedPwd=$(${encryptString} ${defaultPwd})

# Build the response files
log "I Building Connections silent install response files..."
for i in "${icResponseFiles[@]}"
do
    ${cp} ${stagingDir}/rsp/${i}.tmp ${stagingDir}/${icStagingDir}/${i}.xml
    checkStatus ${?} "E Unable to copy ${stagingDir}/rsp/${i}.tmp to ${stagingDir}/${icStagingDir}/${i}.xml. Exiting."
    ${sed} -i "s|FQDN|${fqdn}|" ${i}.xml
    ${sed} -i "s|DNS_SUFFIX|${dnsSuffix}|" ${i}.xml
    ${sed} -i "s|IIM_SHARED_DATA_DIR|${iimSharedDataDir}|" ${i}.xml
    ${sed} -i "s|WAS_INSTALL_DIR|${wasInstallDir}|" ${i}.xml
    ${sed} -i "s|IC_REPOSITORY_DIR|${icRepositoryDir}|" ${i}.xml
    ${sed} -i "s|IC_REPOSITORY_ID|${icRepositoryId}|" ${i}.xml
    ${sed} -i "s|IC_REPOSITORY_VERSION|${icRepositoryVersion}|" ${i}.xml
    ${sed} -i "s|IC_INSTALL_DIR|${icInstallDir}|" ${i}.xml
    ${sed} -i "s|IC_LOCAL_DATA_DIR|${icLocalDataDir}|" ${i}.xml
    ${sed} -i "s|IC_SHARED_DATA_DIR|${icSharedDataDir}|" ${i}.xml
    # The CCM components need hard-coded directories. Scripts like createGCD.sh require these exact paths.
    ${sed} -i "s|CCM_CE_INSTALL_DIR|${icInstallDir}/FileNet/ContentEngine|" ${i}.xml
    ${sed} -i "s|CCM_CECLIENT_INSTALL_DIR|${icInstallDir}/FileNet/CEClient|" ${i}.xml
    ${sed} -i "s|CCM_FNCS_INSTALL_DIR|${icInstallDir}/FNCS|" ${i}.xml
    ${sed} -i "s|CCM_INSTALLER_DIR|${stagingDir}/${icStagingDir}|" ${i}.xml
    ${sed} -i "s|CCM_CE_BASE_PACKAGE|${ccmCEBasePackage}|" ${i}.xml
    ${sed} -i "s|CCM_CE_FP_PACKAGE|${ccmCEFixPackPackage}|" ${i}.xml
    ${sed} -i "s|CCM_CECLIENT_FP_PACKAGE|${ccmCEClientFixPackPackage}|" ${i}.xml
    ${sed} -i "s|CCM_FNCS_BASE_PACKAGE|${ccmFNCSBasePackage}|" ${i}.xml
    ${sed} -i "s|CCM_FNCS_FP_PACKAGE|${ccmFNCSFixPackPackage}|" ${i}.xml
    ${sed} -i "s|DMGR_PROFILE_DIR|${dmgrProfileDir}|" ${i}.xml
    ${sed} -i "s|DMGR_PROFILE_NAME|${dmgrProfileName}|" ${i}.xml
    ${sed} -i "s|JDBC_DIR|${jdbcDir}|" ${i}.xml
    ${sed} -i "s|DB_PWD|${encryptedPwd}|" ${i}.xml
    ${sed} -i "s|DMGR_CELL_NAME|${dmgrCellName}|" ${i}.xml
    ${sed} -i "s|IC_NODE_NAME|${ic1NodeName}|" ${i}.xml
    ${sed} -i "s|WEB_SERVER_NAME|${webServerName}|" ${i}.xml
    ${sed} -i "s|IC_CLUSTER_NAME|${icClusterName}|" ${i}.xml
    ${sed} -i "s|IC_SERVER_NAME|${ic1ServerName}|" ${i}.xml
    ${sed} -i "s|WAS_ADMIN_USER|${dmgrAdminUser}|" ${i}.xml
    ${sed} -i "s|WAS_ADMIN_PWD|${encryptedPwd}|" ${i}.xml
    ${sed} -i "s|IC_ADMIN_USER|${icAdminUser}|" ${i}.xml
    ${sed} -i "s|IC_ADMIN_PWD|${encryptedPwd}|" ${i}.xml
done

# Do a full restart with resync
restartAllWASServersWithNodeSync
checkStatus ${?} "E Unable to restart all WAS servers. Exiting."

# Install the core Connections features first
${installFeature} core
checkStatus ${?} "E Unable to install the Connections core features. Exiting."

# Now install the additional features
${installFeature} activities
checkStatus ${?} "E Unable to install the Connections activities feature. Exiting."
${installFeature} blogs
checkStatus ${?} "E Unable to install the Connections blogs feature. Exiting."
${installFeature} bookmarks
checkStatus ${?} "E Unable to install the Connections bookmarks feature. Exiting."
${installFeature} communities
checkStatus ${?} "E Unable to install the Connections communities feature. Exiting."
${installFeature} forums
checkStatus ${?} "E Unable to install the Connections forums feature. Exiting."
${installFeature} metrics
checkStatus ${?} "E Unable to install the Connections metrics feature. Exiting."
${installFeature} mobile
checkStatus ${?} "E Unable to install the Connections mobile feature. Exiting."
${installFeature} moderation
checkStatus ${?} "E Unable to install the Connections moderation feature. Exiting."
${installFeature} profiles
checkStatus ${?} "E Unable to install the Connections profiles feature. Exiting."
${installFeature} wikis
checkStatus ${?} "E Unable to install the Connections wikis feature. Exiting."
${installFeature} ccm
checkStatus ${?} "E Unable to install the Connections ccm feature. Exiting."

# Print the results
log "I Success! Connections has been installed."
