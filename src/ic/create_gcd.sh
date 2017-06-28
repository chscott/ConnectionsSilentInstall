#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

# Local variables
createGCDScript="${icInstallDir}/ccmDomainTool/creatGCD.sh"

# Do initialization stuff
init ${icStagingDir} configure


# Print the results
