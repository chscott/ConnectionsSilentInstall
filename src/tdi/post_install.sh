#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/tdi/tdi.conf

# Do initialization stuff
init ${tdiStagingDir} configure 

logConfigure 'TDI Post-install Tasks' begin

# Populate Profiles
log "I Populating Profiles..."
${populateProfiles}
checkStatus ${?} "E Unable to populate Profiles. Exiting."

logConfigure 'TDI Post-install Tasks' end 
