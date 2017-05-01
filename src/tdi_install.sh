#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables 
tdiResponseFileTemplate="${stagingDir}/responsefiles/tdi_install.template"
tdiInstallResponseFile="${stagingDir}/${tdiStagingDir}/tdi_install.rsp"
tdiVersion="${tdiInstallDir}/bin/applyUpdates.sh -queryreg"

# Do initialization stuff
init tdi install

# Download the install files 
downloadFile tdi "${tdiBasePackage}"
downloadFile tdi "${tdiFixPackPackage}"

# Unpack the downloaded files
unpackFile tar "${tdiBasePackage}"
unpackFile zip "${tdiFixPackPackage}"

# Build the response file
copyTemplate "${tdiResponseFileTemplate}" "${tdiInstallResponseFile}"
${sed} -i "s|TDI_INSTALL_DIR|${tdiInstallDir}|" ${tdiInstallResponseFile}

# Install TDI
tdiInstallBin=$(ls "${stagingDir}/${tdiStagingDir}/linux_x86_64")
tdiInstall="${stagingDir}/${tdiStagingDir}/linux_x86_64/${tdiInstallBin}"
log "Installing TDI..."
${tdiInstall} -f ${tdiInstallResponseFile} -i silent -D\$TDI_NOSHORTCUTS\$="true"
checkStatus ${?} "ERROR: TDI installation failed. Exiting."

# Print the results
version=$(${tdiVersion} | ${grep} "^Level" | ${cut} -d ' ' -f 2)
log "SUCCESS! TDI ${version} has been installed."
