#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/ic/ic.conf

# Local variables 
feature=${1}

# Do initialization stuff. Use configure option here since we don't want to do any cleanup. That was handled in ic/install.sh
init ic configure 

logInstall "Connections ${feature}" begin

# Install feature 
${imcl} -log ${installFeatureLog} -acceptLicense -input ${stagingDir}/ic/ic_install_${feature}.xml
checkStatus ${?} "E Unable to install the ${feature} feature. Exiting."

logInstall "Connections ${feature}" end
