#!/bin/bash

# Source prereq scripts
. ../src/misc/commands.sh
. ../src/misc/utils.sh
. ../src/misc/vars.sh

# Local variables 
feature=${1}
scriptLog="../logs/script.log"
installLog="../logs/ic_install_${feature}.log"
installPackages="${iimInstallDir}/eclipse/tools/imcl -log ${installLog} -acceptLicense -input"

# Install Activities 
log "I Installing Connections ${feature} feature..."
${installPackages} ${stagingDir}/ic_install_${feature}.xml >>${scriptLog} 2>&1
checkStatus ${?} "E unable to install the ${feature} feature. Exiting."

# Print the results
log "I Success! Connections ${feature} feature has been installed."
