#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/ic/ic.conf

# Do initialization stuff
init ${icStagingDir} configure 

logConfigure 'Connections Pre-install Tasks' begin

# Copy the DB2 driver
${installJdbcDriver}
checkStatus ${?} "E Connections JDBC driver installation failed. Exiting."

logConfigure 'Connections Pre-install Tasks' end 
