#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/tdi/tdi.conf

# Do initialization stuff
init tdi configure 

logConfigure 'TDI Post-install Tasks' begin

# Populate Profiles
log "I Populating Profiles..."
${populateProfiles}
checkStatus ${?} "E Unable to populate Profiles. Exiting."

logConfigure 'TDI Post-install Tasks' end 
