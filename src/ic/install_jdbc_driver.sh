#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/ic/ic.conf

# Do initialization stuff
init ic update 

logConfigure 'Connections JDBC Driver' begin

# Download the JDBC drivers
log "I Downloading JDBC drivers..."
{ ${downloadFile} ${ftpServer} ${ftpDB2Dir} ${jdbcDriver}; ${echo} ${?} >${childProcessTempDir}/ic/${BASHPID}; } &
{ ${downloadFile} ${ftpServer} ${ftpDB2Dir} ${jdbcLicense}; ${echo} ${?} >${childProcessTempDir}/ic/${BASHPID}; } &
wait
checkChildProcessStatus ${childProcessTempDir}/ic
resetChildProcessTempDir ${childProcessTempDir}/ic

# Copy the JDBC drivers to ${jdbcDir}
log "I Copying JDBC driver to ${jdbcDir}..."
${mkdir} -p ${jdbcDir}
checkStatus ${?} "E Unable to create ${jdbcDir}. Exiting."
${cp} -f ${jdbcDriver} ${jdbcDir} 
checkStatus ${?} "E Unable to copy ${jdbcDriver} to ${jdbcDir}. Exiting."
${cp} -f ${jdbcLicense} ${jdbcDir} 
checkStatus ${?} "E Unable to copy ${jdbcLicense} to ${jdbcDir}. Exiting."

logConfigure 'Connections JDBC Driver' end 
