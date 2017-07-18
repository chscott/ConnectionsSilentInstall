#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/ic/ic.conf

# Do initialization stuff
init ic install 

logInstall Connections begin

# Download and unpack the install files 
log "I Downloading Connections installation files..."
{ ${downloadFile} ${ftpServer} ${ftpConnectionsDir} ${icInstallPackage}; ${echo} ${?} >${childProcessTempDir}/ic/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpCCMDir} ${ccmCEBasePackage}; ${echo} ${?} >${childProcessTempDir}/ic/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpCCMDir} ${ccmCEFixPackPackage}; ${echo} ${?} >${childProcessTempDir}/ic/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpCCMDir} ${ccmCEClientFixPackPackage}; ${echo} ${?} >${childProcessTempDir}/ic/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpCCMDir} ${ccmFNCSBasePackage}; ${echo} ${?} >${childProcessTempDir}/ic/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpCCMDir} ${ccmFNCSFixPackPackage}; ${echo} ${?} >${childProcessTempDir}/ic/${BASHPID}; } &
wait
checkChildProcessStatus ${childProcessTempDir}/ic
resetChildProcessTempDir ${childProcessTempDir}/ic
unpackFile tar ${icInstallPackage}

# Extract the component ID and version info
log "I Extracting package IDs and version information from repositories..."
icRepositoryIdVersion=$(${imcl} listAvailablePackages -repositories "${icRepositoryDir}" | ${grep} -F 'com.ibm.connections' | ${sort} | ${tail} -1)
icRepositoryId=$(${echo} ${icRepositoryIdVersion} | ${awk} -F '_' '{print $1}')
icRepositoryVersion=$(${echo} ${icRepositoryIdVersion} | ${awk} -F '_' '{print $2"_"$3"_"$4}')

# Generate an encrypted password
encryptedPwd=$(${imcl} encryptString ${defaultPwd})

# Build the response files
log "I Building Connections silent install response files..."
for i in "${icResponseFiles[@]}"
do
    ${cp} -f ${stagingDir}/rsp/${i}.tmp ${stagingDir}/ic/${i}.xml
    checkStatus ${?} "E Unable to copy ${stagingDir}/rsp/${i}.tmp to ${stagingDir}/ic/${i}.xml. Exiting."
    ${sed} -i "s|DB2_FQDN|${db2Fqdn}|" ${i}.xml
    ${sed} -i "s|DMGR_FQDN|${dmgrFqdn}|" ${i}.xml
    ${sed} -i "s|IHS_FQDN|${ihsFqdn}|" ${i}.xml
    ${sed} -i "s|IC1_FQDN|${ic1Fqdn}|" ${i}.xml
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
    ${sed} -i "s|CCM_INSTALLER_DIR|${stagingDir}/ic|" ${i}.xml
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
    ${sed} -i "s|WEB_SERVER_NAME|${webServerName}|" ${i}.xml
    ${sed} -i "s|IC_CLUSTER_NAME|${icClusterName}|" ${i}.xml
    ${sed} -i "s|IC1_NODE_NAME|${ic1NodeName}|" ${i}.xml
    ${sed} -i "s|IC1_SERVER_NAME|${ic1ServerName}|" ${i}.xml
    ${sed} -i "s|WAS_ADMIN_USER|${dmgrAdminUser}|" ${i}.xml
    ${sed} -i "s|WAS_ADMIN_PWD|${encryptedPwd}|" ${i}.xml
    ${sed} -i "s|IC_ADMIN_USER|${icAdminUser}|" ${i}.xml
    ${sed} -i "s|IC_ADMIN_PWD|${encryptedPwd}|" ${i}.xml
done

# Do a full restart with resync
restartAllWASServersWithNodeSync
checkStatus ${?} "E Unable to restart all WAS servers. Exiting."

# Mandatory feature (Core)

# See if the feature is already installed (0: installed, 1: not installed)
alreadyInstalled=0
for app in "${coreApps[@]}"; do
    result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/${app}")
    if [ ${result} -eq 1 ]; then
        alreadyInstalled=1 
    fi
done
# Install the feature if not already installed
if [ ${alreadyInstalled} -eq 1 ]; then
    ${installFeature} core
    checkStatus ${?} "E Unable to install the Core features. Exiting."
else
    log "I The Core features are already installed. Skipping."
fi

# Optional features

# Activities
if [ ${installIcActivities} == 'true' ]; then
    alreadyInstalled=0
    result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/Activities.ear")
    if [ ${result} -eq 1 ]; then
        alreadyInstalled=1 
    fi
    # Install the feature if not already installed
    if [ ${alreadyInstalled} -eq 1 ]; then
        ${installFeature} activities
        checkStatus ${?} "E Unable to install the Activities feature. Exiting."
    else
        log "I The Activities feature is already installed. Skipping."
    fi
else
    log "I The Activities feature has not been enabled for install in ${stagingDir}/src/misc/vars.conf. Skipping."
fi

# Blogs
if [ ${installIcBlogs} == 'true' ]; then
    alreadyInstalled=0
    result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/Blogs.ear")
    if [ ${result} -eq 1 ]; then
        alreadyInstalled=1 
    fi
    # Install the feature if not already installed
    if [ ${alreadyInstalled} -eq 1 ]; then
        ${installFeature} blogs
        checkStatus ${?} "E Unable to install the Blogs feature. Exiting."
    else
        log "I The Blogs feature is already installed. Skipping."
    fi
else
    log "I The Blogs feature has not been enabled for install in ${stagingDir}/src/misc/vars.conf. Skipping."
fi

# Bookmarks
if [ ${installIcBookmarks} == 'true' ]; then
    alreadyInstalled=0
    result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/Dogear.ear")
    if [ ${result} -eq 1 ]; then
        alreadyInstalled=1 
    fi
    # Install the feature if not already installed
    if [ ${alreadyInstalled} -eq 1 ]; then
        ${installFeature} bookmarks
        checkStatus ${?} "E Unable to install the Bookmarks feature. Exiting."
    else
        log "I The Bookmarks feature is already installed. Skipping."
    fi
else
    log "I The Bookmarks feature has not been enabled for install in ${stagingDir}/src/misc/vars.conf. Skipping."
fi

# Communities
if [ ${installIcCommunities} == 'true' ]; then
    alreadyInstalled=0
    result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/Communities.ear")
    if [ ${result} -eq 1 ]; then
        alreadyInstalled=1 
    fi
    # Install the feature if not already installed
    if [ ${alreadyInstalled} -eq 1 ]; then
        ${installFeature} communities
        checkStatus ${?} "E Unable to install the Communities feature. Exiting."
    else
        log "I The Communities feature is already installed. Skipping."
    fi
else
    log "I The Communities feature has not been enabled for install in ${stagingDir}/src/misc/vars.conf. Skipping."
fi

# Forum
if [ ${installIcForum} == 'true' ]; then
    alreadyInstalled=0
    result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/Forums.ear")
    if [ ${result} -eq 1 ]; then
        alreadyInstalled=1 
    fi
    # Install the feature if not already installed
    if [ ${alreadyInstalled} -eq 1 ]; then
        ${installFeature} forum
        checkStatus ${?} "E Unable to install the Forum feature. Exiting."
    else
        log "I The Forum feature is already installed. Skipping."
    fi
else
    log "I The Forum feature has not been enabled for install in ${stagingDir}/src/misc/vars.conf. Skipping."
fi

# Metrics
if [ ${installIcMetrics} == 'true' ]; then
    alreadyInstalled=0
    result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/Metrics.ear")
    if [ ${result} -eq 1 ]; then
        alreadyInstalled=1 
    fi
    # Install the feature if not already installed
    if [ ${alreadyInstalled} -eq 1 ]; then
        ${installFeature} metrics
        checkStatus ${?} "E Unable to install the Metrics feature. Exiting."
    else
        log "I The Metrics feature is already installed. Skipping."
    fi
else
    log "I The Metrics feature has not been enabled for install in ${stagingDir}/src/misc/vars.conf. Skipping."
fi

# Mobile
if [ ${installIcMobile} == 'true' ]; then
    alreadyInstalled=0
    for app in "${mobileApps[@]}"; do
        result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/${app}")
        if [ ${result} -eq 1 ]; then
            alreadyInstalled=1 
        fi
    done
    # Install the feature if not already installed
    if [ ${alreadyInstalled} -eq 1 ]; then
        ${installFeature} mobile
        checkStatus ${?} "E Unable to install the Mobile feature. Exiting."
    else
        log "I The Mobile feature is already installed. Skipping."
    fi
else
    log "I The Mobile feature has not been enabled for install in ${stagingDir}/src/misc/vars.conf. Skipping."
fi

# Moderation
if [ ${installIcModeration} == 'true' ]; then
    alreadyInstalled=0
    result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/Moderation.ear")
    if [ ${result} -eq 1 ]; then
        alreadyInstalled=1 
    fi
    # Install the feature if not already installed
    if [ ${alreadyInstalled} -eq 1 ]; then
        ${installFeature} moderation
        checkStatus ${?} "E Unable to install the Moderation feature. Exiting."
    else
        log "I The Moderation feature is already installed. Skipping."
    fi
else
    log "I The Moderation feature has not been enabled for install in ${stagingDir}/src/misc/vars.conf. Skipping."
fi

# Profiles
if [ ${installIcProfiles} == 'true' ]; then
    alreadyInstalled=0
    result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/Profiles.ear")
    if [ ${result} -eq 1 ]; then
        alreadyInstalled=1 
    fi
    # Install the feature if not already installed
    if [ ${alreadyInstalled} -eq 1 ]; then
        ${installFeature} profiles
        checkStatus ${?} "E Unable to install the Profiles feature. Exiting."
    else
        log "I The Profiles feature is already installed. Skipping."
    fi
else
    log "I The Profiles feature has not been enabled for install in ${stagingDir}/src/misc/vars.conf. Skipping."
fi

# Wikis
if [ ${installIcWikis} == 'true' ]; then
    alreadyInstalled=0
    result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/Wikis.ear")
    if [ ${result} -eq 1 ]; then
        alreadyInstalled=1 
    fi
    # Install the feature if not already installed
    if [ ${alreadyInstalled} -eq 1 ]; then
        ${installFeature} wikis
        checkStatus ${?} "E Unable to install the Wikis feature. Exiting."
    else
        log "I The Wikis feature is already installed. Skipping."
    fi
else
    log "I The Wikis feature has not been enabled for install in ${stagingDir}/src/misc/vars.conf. Skipping."
fi

# CCM
if [ ${installIcCCM} == 'true' ]; then
    alreadyInstalled=0
    for app in "${ccmApps[@]}"; do
        result=$(isInstalled "${dmgrProfileDir}/config/cells/${dmgrCellName}/applications/${app}")
        if [ ${result} -eq 1 ]; then
            alreadyInstalled=1 
        fi
    done
    # Install the feature if not already installed
    if [ ${alreadyInstalled} -eq 1 ]; then
        ${installFeature} ccm
        checkStatus ${?} "E Unable to install the CCM feature. Exiting."
    else
        log "I The CCM feature is already installed. Skipping."
    fi
else
    log "I The CCM feature has not been enabled for install in ${stagingDir}/src/misc/vars.conf. Skipping."
fi

logInstall Connections end
