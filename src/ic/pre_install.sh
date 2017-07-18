#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/ic/ic.conf

# Do initialization stuff
init ic configure 

logConfigure 'Connections Pre-install Tasks' begin

# Copy the DB2 driver
${installJdbcDriver}
checkStatus ${?} "E Connections JDBC driver installation failed. Exiting."

logConfigure 'Connections Pre-install Tasks' end 
