#!/bin/bash

# Source prereq scripts
. ../src/misc/commands.sh
. ../src/misc/utils.sh
. ../src/misc/vars.conf
. ../src/ic/ic.conf

# Local variables 
feature=${1}

# Do initialization stuff. Use configure option here since we don't want to do any cleanup. That was handled in ic/install.sh
init ${icStagingDir} configure 

logInstall "Connections ${feature}" begin

# Install feature 
${imcl} -log ${installFeatureLog} -acceptLicense -input ${stagingDir}/ic_install_${feature}.xml
checkStatus ${?} "E Unable to install the ${feature} feature. Exiting."

logInstall "Connections ${feature}" end
