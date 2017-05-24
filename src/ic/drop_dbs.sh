#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

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

log "I Beginning drop of Connections databases..."

# Do initialization stuff
init ${icDbStagingDir} uninstall 

# Drop the databases 
for i in "${icDbs[@]}"
do
    if [ ${i} == "communities" ]; then
        log "I Dropping calendar database for: ${i}..."    
        ${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/${i}/db2/calendar-dropDb.sql >>${icDbLog} 2>&1"; result=${?}
        checkStatusDb drop ${result} "W calendar-dropDb.sql failed. Database may not exist. Continuing..."
    fi
    log "I Dropping database for: ${i}..."    
    ${su} - ${db2InstanceUser} -c "db2 -td@ -f ${icDbScriptDir}/${i}/db2/dropDb.sql >>${icDbLog} 2>&1"; result=${?}
    checkStatusDb drop ${result} "W dropDb.sql failed. Database may not exist. Continuing..."
done

# Print the results
log "I Success! Connections databases have been dropped"
