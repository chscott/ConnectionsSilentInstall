#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/db2/db2.conf

# Do initialization stuff
init ${db2StagingDir} update 

logInstall 'Connections Databases' begin

# Download and unpack the install files 
log "I Downloading database creation scripts..."
{ ${downloadFile} ${ftpServer} ${ftpConnectionsDir} ${icDbPackage}; ${echo} ${?} >${childProcessTempDir}/${db2StagingDir}/${BASHPID}; } &
wait
checkChildProcessStatus ${childProcessTempDir}/${db2StagingDir}
unpackFile tar ${icDbPackage}
${chown} -R ${db2InstanceUser}.${db2InstanceGroup} Wizards

# Create the databases. Note that there is no database for Moderation

# Create the Core databases (these are mandatory since Core is mandatory)
log 'I Creating databases for Core...'
# Homepage
${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'HOMEPAGE'"; result=${?}
if [ ${result} -eq 0 ]; then
    log "W Homepage database is already created. Skipping."
else
    ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/createDb.sql"; result=${?}
    checkStatusDb create ${result} 'E Unable to create database: Homepage. Exiting.' 
    ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/appGrants.sql"; result=${?} 
    checkStatusDb create ${result} 'E Unable to grant rights on database: Homepage. Exiting.' 
    ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/initData.sql"; result=${?}
    checkStatusDb create ${result} 'E Unable to initialize data for database: Homepage. Exiting.'
    ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/reorg.sql"; result=${?}
    checkStatusDb create ${result} 'E Unable to run reorg on database: Homepage. Exiting.'
    ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/updateStats.sql"; result=${?}
    checkStatusDb create ${result} 'E Unable to update stats for database: Homepage. Exiting.'
fi
# Files
${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'FILES'"; result=${?}
if [ ${result} -eq 0 ]; then
    log "W Files database is already created. Skipping."
else
    ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/files/db2/createDb.sql"; result=${?}
    checkStatusDb create ${result} 'E Unable to create database: Files. Exiting.' 
    ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/files/db2/appGrants.sql"; result=${?} 
    checkStatusDb create ${result} 'E Unable to grant rights on database: Files. Exiting.' 
fi
# Push Notification
${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'PNS'"; result=${?}
if [ ${result} -eq 0 ]; then
    log "W PNS database is already created. Skipping."
else
    ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/pushnotification/db2/createDb.sql"; result=${?}
    checkStatusDb create ${result} 'E Unable to create database: Push Notification. Exiting.' 
    ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/pushnotification/db2/appGrants.sql"; result=${?} 
    checkStatusDb create ${result} 'E Unable to grant rights on database: Push Notification. Exiting.' 
fi

# Create the Activities database
if [ ${installIcActivities} == 'true' ]; then
    log 'I Creating database for Activities...'
    ${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'OPNACT'"; result=${?}
    if [ ${result} -eq 0 ]; then
        log "W OPNACT database is already created. Skipping."
    else
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/activities/db2/createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create database: Activities. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/activities/db2/appGrants.sql"; result=${?} 
        checkStatusDb create ${result} 'E Unable to grant rights on database: Activities. Exiting.' 
    fi
else
    log 'I Will not create database for Activities since it is not being installed.'
fi

# Create the Blogs database
if [ ${installIcBlogs} == 'true' ]; then
    log 'I Creating database for Blogs...'
    ${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'BLOGS'"; result=${?}
    if [ ${result} -eq 0 ]; then
        log "W BLOGS database is already created. Skipping."
    else
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/blogs/db2/createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create database: Blogs. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/blogs/db2/appGrants.sql"; result=${?} 
        checkStatusDb create ${result} 'E Unable to grant rights on database: Blogs. Exiting.' 
    fi
else
    log 'I Will not create database for Blogs since it is not being installed.'
fi

# Create the Bookmarks database
if [ ${installIcBookmarks} == 'true' ]; then
    log 'I Creating database for Bookmarks...'
    ${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'DOGEAR'"; result=${?}
    if [ ${result} -eq 0 ]; then
        log "W DOGEAR database is already created. Skipping."
    else
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/dogear/db2/createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create database: Bookmarks. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/dogear/db2/appGrants.sql"; result=${?} 
        checkStatusDb create ${result} 'E Unable to grant rights on database: Bookmarks. Exiting.' 
    fi
else
    log 'I Will not create database for Bookmarks since it is not being installed.'
fi

# Create the Communities database
if [ ${installIcCommunities} == 'true' ]; then
    log 'I Creating database for Communities...'
    ${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'SNCOMM'"; result=${?}
    if [ ${result} -eq 0 ]; then
        log "W SNCOMM database is already created. Skipping."
    else
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/communities/db2/createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create database: Communities. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/communities/db2/appGrants.sql"; result=${?} 
        checkStatusDb create ${result} 'E Unable to grant rights on database: Communities. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/communities/db2/calendar-createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create table: Calendar. Exiting.'
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/communities/db2/calendar-appGrants.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to grant rights on table: Calendar. Exiting.'
    fi
else
    log 'I Will not create database for Communities since it is not being installed.'
fi

# Create the Forum database
if [ ${installIcForum} == 'true' ]; then
    log 'I Creating database for Forum...'
    ${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'FORUM'"; result=${?}
    if [ ${result} -eq 0 ]; then
        log "W FORUM database is already created. Skipping."
    else
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/forum/db2/createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create database: Forum. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/forum/db2/appGrants.sql"; result=${?} 
        checkStatusDb create ${result} 'E Unable to grant rights on database: Forum. Exiting.' 
    fi
else
    log 'I Will not create database for Forum since it is not being installed.'
fi

# Create the Metrics database
if [ ${installIcMetrics} == 'true' ]; then
    log 'I Creating database for Metrics...'
    ${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'METRICS'"; result=${?}
    if [ ${result} -eq 0 ]; then
        log "W METRICS database is already created. Skipping."
    else
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/metrics/db2/createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create database: Metrics. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/metrics/db2/appGrants.sql"; result=${?} 
        checkStatusDb create ${result} 'E Unable to grant rights on database: Metrics. Exiting.' 
    fi
else
    log 'I Will not create database for Metrics since it is not being installed.'
fi

# Create the Mobile database
if [ ${installIcMobile} == 'true' ]; then
    log 'I Creating database for Mobile...'
    ${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'MOBILE'"; result=${?}
    if [ ${result} -eq 0 ]; then
        log "W MOBILE database is already created. Skipping."
    else
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/mobile/db2/createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create database: Mobile. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/mobile/db2/appGrants.sql"; result=${?} 
        checkStatusDb create ${result} 'E Unable to grant rights on database: Mobile. Exiting.' 
    fi
else
    log 'I Will not create database for Mobile since it is not being installed.'
fi

# Create the Profiles database
if [ ${installIcProfiles} == 'true' ]; then
    log 'I Creating database for Profiles...'
    ${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'PEOPLEDB'"; result=${?}
    if [ ${result} -eq 0 ]; then
        log "W PEOPLEDB database is already created. Skipping."
    else
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/profiles/db2/createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create database: Profiles. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/profiles/db2/appGrants.sql"; result=${?} 
        checkStatusDb create ${result} 'E Unable to grant rights on database: Profiles. Exiting.' 
    fi
else
    log 'I Will not create database for Profiles since it is not being installed.'
fi

# Create the Wikis database
if [ ${installIcWikis} == 'true' ]; then
    log 'I Creating database for Wikis...'
    ${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'WIKIS'"; result=${?}
    if [ ${result} -eq 0 ]; then
        log "W WIKIS database is already created. Skipping."
    else
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/wikis/db2/createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create database: Wikis. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/wikis/db2/appGrants.sql"; result=${?} 
        checkStatusDb create ${result} 'E Unable to grant rights on database: Wikis. Exiting.' 
    fi
else
    log 'I Will not create database for Wikis since it is not being installed.'
fi

# Create the CCM databases
if [ ${installIcCCM} == 'true' ]; then
    log 'I Creating databases for CCM...'
    # GCD
    ${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'FNGCD'"; result=${?}
    if [ ${result} -eq 0 ]; then
        log "W FNGCD database is already created. Skipping."
    else
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/library.gcd/db2/createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create database: GCD. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/library.gcd/db2/appGrants.sql"; result=${?} 
        checkStatusDb create ${result} 'E Unable to grant rights on database: GCD. Exiting.' 
    fi
    # OS
    ${su} - ${db2InstanceUser} -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'FNOS'"; result=${?}
    if [ ${result} -eq 0 ]; then
        log "W FNOS database is already created. Skipping."
    else
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/library.os/db2/createDb.sql"; result=${?}
        checkStatusDb create ${result} 'E Unable to create database: OS. Exiting.' 
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/library.os/db2/appGrants.sql"; result=${?} 
        checkStatusDb create ${result} 'E Unable to grant rights on database: OS. Exiting.' 
    fi
else
    log 'I Will not create databases for CCM since it is not being installed.'
fi

logInstall 'Connections Databases' end
