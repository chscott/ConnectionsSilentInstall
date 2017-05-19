#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables 
icDbScriptDir="${stagingDir}/${icStagingDir}/${icDbStagingDir}/Wizards/connections.sql"
icDbLog="${logDir}/ic_drop_dbs.log"
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
init ${icDbStagingDir} uninstall 

# Drop the databases 
for i in "${icDbs[@]}"
do
    if [ ${i} == "communities" ]; then
        log "INFO: Dropping calendar database for: ${i}..."    
        ${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/${i}/db2/calendar-dropDb.sql >>${icDbLog} 2>&1"; result=${?}
        checkStatusDb drop ${result} "WARNING: calendar-dropDb.sql failed. Database may not exist. Continuing..."
    fi
    log "INFO: Dropping database for: ${i}..."    
    ${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/${i}/db2/dropDb.sql >>${icDbLog} 2>&1"; result=${?}
    checkStatusDb drop ${result} "WARNING: dropDb.sql failed. Database may not exist. Continuing..."
done

# Print the results
log "INFO: Success! Connections databases have been dropped"
