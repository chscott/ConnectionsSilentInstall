#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/main/main.conf

# Do initialization stuff
init main main_install

logInstall 'All Components' begin

# Install selected components. Components check to see if their prereqs are installed, so no need to check here
if [ ${installDb2} == "true" ]; then
    ${installDb2Script}
    checkStatus ${?} "E DB2 installation failed. Exiting."
    ${createDbsScript}
    checkStatus ${?} "E Connections database creation failed. Exiting."
fi
if [ ${installTdi} == "true" ]; then
    ${installTdiScript}
    checkStatus ${?} "E TDI installation failed. Exiting."
    ${postInstallTdiScript}
    checkStatus ${?} "E TDI post-installation tasks failed. Exiting."
fi
if [ ${installIim} == "true" ]; then
    ${installIimScript}
    checkStatus ${?} "E IIM installation failed. Exiting."
fi
if [ ${installWeb} == "true" ]; then
    ${installWebScript}
    checkStatus ${?} "E WebSphere installation failed. Exiting."
    ${postInstallWebScript}
    checkStatus ${?} "E WebSphere post-installation tasks failed. Exiting."
fi
if [ ${installIc} == "true" ]; then
    ${preInstallIcScript}
    checkStatus ${?} "E Connections pre-installation tasks failed. Exiting."
    ${installIcScript}
    checkStatus ${?} "E Connections installation failed. Exiting."
    ${postInstallIcScript}
    checkStatus ${?} "E Connections post-installation tasks failed. Exiting."
fi

logInstall 'All Components' end
