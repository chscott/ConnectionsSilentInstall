#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables 
icInstallLog="${logDir}/ic_install.log"
listAvailablePackages="${iimInstallDir}/eclipse/tools/imcl listAvailablePackages -repositories"
installPackages="${iimInstallDir}/eclipse/tools/imcl -log ${icInstallLog} -acceptLicense -input"
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
    ${icWikisRsp}
)

# Do initialization stuff
init ${icStagingDir} install 

# Download the install files 
downloadFile connections ${icInstallPackage}

# Unpack the downloaded files
unpackFile tar ${icInstallPackage}

# Extract the component ID and version info
log "INFO: Extracting package IDs and version information from repositories..."
icRepositoryIdVersion=$(${listAvailablePackages} "${icRepositoryDir}" | ${grep} -F 'com.ibm.connections' | ${sort} | ${tail} -1)
icRepositoryId=$(echo ${icRepositoryIdVersion} | awk -F '_' '{print $1}')
icRepositoryVersion=$(echo ${icRepositoryIdVersion} | awk -F '_' '{print $2"_"$3"_"$4}')

# Generate an encrypted password
encryptedPwd=$(${encryptString} ${defaultPwd})

# Build the response files
log "INFO: Building Connection silent install response files..."
for i in "${icResponseFiles[@]}"
do
    ${cp} ${stagingDir}/rsp/${i}.tmp ${stagingDir}/${icStagingDir}/${i}.xml
    checkStatus ${?} "ERROR: Unable to copy ${stagingDir}/rsp/${i}.tmp to ${stagingDir}/${icStagingDir}/${i}.xml. Exiting."
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
    ${sed} -i "s|CCM_CE_INSTALL_DIR|${ccmCEInstallDir}|" ${i}.xml
    ${sed} -i "s|CCM_CECLIENT_INSTALL_DIR|${ccmCEClientInstallDir}|" ${i}.xml
    ${sed} -i "s|CCM_FNCS_INSTALL_DIR|${ccmFNCSInstallDir}|" ${i}.xml
    ${sed} -i "s|DMGR_PROFILE_DIR|${dmgrProfileDir}|" ${i}.xml
    ${sed} -i "s|DMGR_PROFILE_NAME|${dmgrProfileName}|" ${i}.xml
    ${sed} -i "s|JDBC_DIR|${jdbcDir}|" ${i}.xml
    ${sed} -i "s|DB_PWD|${encryptedPwd}|" ${i}.xml
    ${sed} -i "s|DMGR_CELL_NAME|${dmgrCellName}|" ${i}.xml
    ${sed} -i "s|IC_NODE_NAME|${icNodeName}|" ${i}.xml
    ${sed} -i "s|WEB_SERVER_NAME|${webServerName}|" ${i}.xml
    ${sed} -i "s|IC_CLUSTER_NAME|${icClusterName}|" ${i}.xml
    ${sed} -i "s|IC_SERVER_NAME|${icServerName}|" ${i}.xml
    ${sed} -i "s|WAS_ADMIN_USER|${dmgrAdminUser}|" ${i}.xml
    ${sed} -i "s|WAS_ADMIN_PWD|${encryptedPwd}|" ${i}.xml
    ${sed} -i "s|IC_ADMIN_USER|${icAdminUser}|" ${i}.xml
    ${sed} -i "s|IC_ADMIN_PWD|${encryptedPwd}|" ${i}.xml
done

# Make sure the WAS servers are running
result=$(startWASServer dmgr ${dmgrProfileDir})
checkStatus ${result} "ERROR: Unable to start deployment manager. Exiting."
result=$(startWASServer nodeagent ${icProfileDir})
checkStatus ${result} "ERROR: Unable to start node agent. Exiting."

# Make sure the IHS servers are running
result=$(startIHSAdminServer)
checkStatus ${result} "ERROR: Unable to start IHS administration server. Exiting."
result=$(startIHSServer)
checkStatus ${result} "ERROR: Unable to start IHS. Exiting."

# Install the core Connections features
log "INFO: Installing the Connections core features..."
${installPackages} ${stagingDir}/${icStagingDir}/${icCoreRsp}.xml >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to install the Connections core features. Exiting."

# Install Activities 
log "INFO: Installing the Activities feature..."
${installPackages} ${stagingDir}/${icStagingDir}/${icActivitiesRsp}.xml >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to install the Activities feature. Exiting."

# Install Blogs 
log "INFO: Installing the Blogs feature..."
${installPackages} ${stagingDir}/${icStagingDir}/${icBlogsRsp}.xml >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to install the Blogs feature. Exiting."

# Install Bookmarks 
log "INFO: Installing the Bookmarks feature..."
${installPackages} ${stagingDir}/${icStagingDir}/${icBookmarksRsp}.xml >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to install the Bookmarks feature. Exiting."

# Install Communities 
log "INFO: Installing the Communities feature..."
${installPackages} ${stagingDir}/${icStagingDir}/${icCommunitiesRsp}.xml >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to install the Communities feature. Exiting."

# Install Forums 
log "INFO: Installing the Forums feature..."
${installPackages} ${stagingDir}/${icStagingDir}/${icForumsRsp}.xml >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to install the Forums feature. Exiting."

# Install Metrics 
log "INFO: Installing the Metrics feature..."
${installPackages} ${stagingDir}/${icStagingDir}/${icMetricsRsp}.xml >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to install the Metrics feature. Exiting."

# Install Mobile 
log "INFO: Installing the Mobile feature..."
${installPackages} ${stagingDir}/${icStagingDir}/${icMobileRsp}.xml >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to install the Mobile feature. Exiting."

# Install Moderation 
log "INFO: Installing the Moderation feature..."
${installPackages} ${stagingDir}/${icStagingDir}/${icModerationRsp}.xml >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to install the Moderation feature. Exiting."

# Install Profiles 
log "INFO: Installing the Profiles feature..."
${installPackages} ${stagingDir}/${icStagingDir}/${icProfilesRsp}.xml >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to install the Profiles feature. Exiting."

# Install Wikis 
log "INFO: Installing the Wikis feature..."
${installPackages} ${stagingDir}/${icStagingDir}/${icWikisRsp}.xml >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: unable to install the Wikis feature. Exiting."

# Start Connections
result=$(startWASServer ${icServerName} ${icProfileDir})
checkStatus ${result} "ERROR: Unable to start Connections application server. Exiting."

# Print the results
log "INFO: Success! Connections has been installed."
