#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/db2/db2.conf

# Do initialization stuff
init db2 uninstall 

logUninstall 'Connections Databases' begin

# Drop the databases. Don't check if the component is configured to be installed. Will just skip if the database isn't present.

# Core
log 'I Dropping databases for Core...'
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/homepage/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Homepage. Database may not exist. Continuing..."
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/files/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Files. Database may not exist. Continuing..."
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/pushnotification/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Push Notification. Database may not exist. Continuing..."

# Activities
log 'I Dropping database for Activities...'
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/activities/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Activities. Database may not exist. Continuing..."

# Blogs
log 'I Dropping database for Blogs...'
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/blogs/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Blogs. Database may not exist. Continuing..."

# Bookmarks
log 'I Dropping database for Bookmarks'
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/dogear/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Bookmarks. Database may not exist. Continuing..."

# Communities
log 'I Dropping database for Communities...'
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/communities/db2/calendar-dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop table: Communities Calendar. Table may not exist. Continuing..."
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/communities/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Communities. Database may not exist. Continuing..."

# Forum
log 'I Dropping database for Forum...'
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/forum/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Forum. Database may not exist. Continuing..."

# Metrics
log 'I Dropping database for Metrics...'
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/metrics/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Metrics. Database may not exist. Continuing..."

# Mobile
log 'I Dropping database for Mobile...'
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/mobile/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Mobile. Database may not exist. Continuing..."

# Profiles
log 'I Dropping database for Profiles...'
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/profiles/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Profiles. Database may not exist. Continuing..."

# Wikis
log 'I Dropping database for Wikis...'
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/wikis/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: Wikis. Database may not exist. Continuing..."

# CCM
log 'I Dropping databases for CCM...'
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/library.gcd/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: GCD. Database may not exist. Continuing..."
${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/library.os/db2/dropDb.sql"; result=${?}
checkStatusDb drop ${result} "Unable to drop database: OS. Database may not exist. Continuing..."

logInstall 'Connections Databases' end
