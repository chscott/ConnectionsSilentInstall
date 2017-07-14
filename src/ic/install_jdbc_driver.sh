#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/ic/ic.conf

# Do initialization stuff
init ${icStagingDir} install 

logConfigure 'Connections JDBC Driver' begin

# Download the JDBC drivers
log "I Downloading JDBC drivers..."
{ ${downloadFile} ${ftpServer} ${ftpDB2Dir} ${jdbcDriver}; ${echo} ${?} >${childProcessTempDir}/${icStagingDir}/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpDB2Dir} ${jdbcLicense}; ${echo} ${?} >${childProcessTempDir}/${icStagingDir}/${BASHPID}; } &
wait
checkChildProcessStatus ${childProcessTempDir}/${icStagingDir}
resetChildProcessTempDir ${childProcessTempDir}/${icStagingDir}

# Copy the JDBC drivers to ${jdbcDir}
log "I Copying JDBC driver to ${jdbcDir}..."
${mkdir} -p ${jdbcDir}
checkStatus ${?} "E Unable to create ${jdbcDir}. Exiting."
${cp} -f ${jdbcDriver} ${jdbcDir} 
checkStatus ${?} "E Unable to copy ${jdbcDriver} to ${jdbcDir}. Exiting."
${cp} -f ${jdbcLicense} ${jdbcDir} 
checkStatus ${?} "E Unable to copy ${jdbcLicense} to ${jdbcDir}. Exiting."

logConfigure 'Connections JDBC Driver' end 
