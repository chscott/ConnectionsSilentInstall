#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables 
downloadFile="../src/misc/downloadFile.sh"
icDbScriptDir="${stagingDir}/${icDbStagingDir}/Wizards/connections.sql"
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

log "I Beginning creation of Connections databases..."

# Do initialization stuff
init ${icDbStagingDir} install 

# Download the install files 
log "I Downloading database creation scripts..."
{ ${downloadFile} ${ftpServer} ${ftpConnectionsDir} ${icDbPackage}; ${echo} ${?} >${childProcessTempDir}/${icDbStagingDir}/${BASHPID}; } &

# Wait for file downloads to complete and then check status
wait
checkChildProcessStatus ${childProcessTempDir}/${icDbStagingDir}

# Unpack the downloaded files
unpackFile tar ${icDbPackage}
${chown} -R ${db2InstanceUser}.${db2InstanceGroup} Wizards

# Recreate the child process temp dir for dbs
resetChildProcessTempDir ${childProcessTempDir}/${icDbStagingDir}

# Create the databases
counter=1
for i in "${icDbs[@]}"; do
    log "I Creating database for: ${i}..."    
    { ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/${i}/db2/createDb.sql >>${icDbLog} 2>&1"; \
      ${echo} ${?} >${childProcessTempDir}/${icDbStagingDir}/${BASHPID}; } & 
    # Wait every batchSize iterations to avoid I/O issues
    if [[ $(( ${counter} % ${batchSize} )) -eq 0 ]]; then
        wait
        checkChildProcessStatusDb "create" 
        resetChildProcessTempDir ${childProcessTempDir}/${icDbStagingDir} 
    fi
    counter=$(( ${counter} + 1 ))
done

# Create the calendar table for communities
log "I Creating calendar table for communities..."    
${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/communities/db2/calendar-createDb.sql >>${icDbLog} 2>&1"; result=${?}
checkStatusDb create ${result} "E calendar-createDb.sql failed. Exiting."
${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/communities/db2/calendar-appGrants.sql >>${icDbLog} 2>&1"; result=${?}
checkStatusDb create ${result} "E calendar-appGrants.sql failed. Exiting."

# Grant rights on the databases
counter=1
for i in "${icDbs[@]}"; do
    log "I Granting rights on: ${i}..."    
    { ${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/${i}/db2/appGrants.sql >>${icDbLog} 2>&1"; \
      ${echo} ${?} >${childProcessTempDir}/${icDbStagingDir}/${BASHPID}; } & 
    # Wait every batchSize iterations to avoid I/O issues
    if [[ $(( ${counter} % ${batchSize} )) -eq 0 ]]; then
        wait
        checkChildProcessStatusDb "create" 
        resetChildProcessTempDir ${childProcessTempDir}/${icDbStagingDir} 
    fi
    counter=$(( ${counter} + 1 ))
done

# Run additional maintenance scripts for homepage
log "I Running maintenance on homepage..."
${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/initData.sql >>${icDbLog} 2>&1"; result=${?}
checkStatusDb create ${result} "E initData.sql failed. Exiting."
${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/reorg.sql >>${icDbLog} 2>&1"; result=${?}
checkStatusDb create ${result} "E reorg.sql failed. Exiting."
${su} - ${db2InstanceUser} -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/updateStats.sql >>${icDbLog} 2>&1"; result=${?}
checkStatusDb create ${result} "E updateStats.sql failed. Exiting."

# Print the results
log "I Success! Connections databases have been created."
