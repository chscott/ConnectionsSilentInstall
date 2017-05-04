#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables 
icDbScriptDir="${stagingDir}/${icStagingDir}/${icDbStagingDir}/Wizards/connections.sql"
icDbLog="${logDir}/ic_create_dbs.log"
icDbs=( \
    homepage \
    profiles \
    activities \
    communities \
    blogs \
    dogear \
    files \
    forum \
    mobile \
    pushnotification \
    wikis \
    metrics \
    cognos \
    library.gcd \
    library.os \
    )

# Do initialization stuff
init ${icStagingDir}/${icDbStagingDir} install 

# Download the install files 
downloadFile connections ${icDbPackage}

# Unpack the downloaded files
unpackFile tar ${icDbPackage}
${chown} -R ${db2InstanceUser}.${db2InstanceGroup} Wizards

# Create the databases 
for i in "${icDbs[@]}"
do
    log "Creating database for: ${i}..."    
    ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/${i}/db2/createDb.sql >>${icDbLog} 2>&1"; result=${?}
    checkStatusDb create ${result} "ERROR: createDb.sql failed. Exiting."
    ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/${i}/db2/appGrants.sql >>${icDbLog} 2>&1"; result=${?}
    checkStatusDb create ${result} "ERROR: appGrants.sql failed. Exiting."
    if [ ${i} == "homepage" ]; then
        log "Running maintenance on ${i}..."
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/${i}/db2/initData.sql >>${icDbLog} 2>&1"; result=${?}
        checkStatusDb create ${result} "ERROR: initData.sql failed. Exiting."
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/${i}/db2/reorg.sql >>${icDbLog} 2>&1"; result=${?}
        checkStatusDb create ${result} "ERROR: reorg.sql failed. Exiting."
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/${i}/db2/updateStats.sql >>${icDbLog} 2>&1"; result=${?}
        checkStatusDb create ${result} "ERROR: updateStats.sql failed. Exiting."
    elif [ ${i} == "communities" ]; then
        log "Creating calendar database for: ${i}..."    
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/${i}/db2/calendar-createDb.sql >>${icDbLog} 2>&1"; result=${?}
        checkStatusDb create ${result} "ERROR: calendar-createDb.sql failed. Exiting."
        ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/${i}/db2/calendar-appGrants.sql >>${icDbLog} 2>&1"; result=${?}
        checkStatusDb create ${result} "ERROR: calendar-appGrants.sql failed. Exiting."
    fi
done

# Print the results
log "Success! Connections databases have been created."
