#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables 
tdiResponseFileTemplate="${stagingDir}/rsp/tdi_install.tmp"
tdiInstallResponseFile="${stagingDir}/${tdiStagingDir}/tdi_install.rsp"
tdiVersion="${tdiInstallDir}/bin/applyUpdates.sh -queryreg"
tdiFixPackDir=$(${echo} ${tdiFixPackPackage} | ${awk} -F '.zip' '{print $1}')
updateInstaller="${stagingDir}/${tdiStagingDir}/${tdiFixPackDir}/UpdateInstaller.jar"
fixPackFile="$(${echo} ${tdiFixPackPackage} | ${awk} -F '-' '{print $3"-"$1"-"$4}')"
fixPack=${stagingDir}/${tdiStagingDir}/${tdiFixPackDir}/${fixPackFile}

log "INSTALL: Beginning installation of TDI..."

# Do initialization stuff
init ${tdiStagingDir} install

# Download the install files 
downloadFile tdi ${tdiBasePackage}
downloadFile tdi ${tdiFixPackPackage}

# Unpack the downloaded files
unpackFile tar ${tdiBasePackage}
unpackFile zip ${tdiFixPackPackage}

# Build the response file
copyTemplate ${tdiResponseFileTemplate} ${tdiInstallResponseFile}
${sed} -i "s|TDI_INSTALL_DIR|${tdiInstallDir}|" ${tdiInstallResponseFile}

# Install TDI Base
tdiInstallBin=$(ls "${stagingDir}/${tdiStagingDir}/linux_x86_64")
tdiInstall="${stagingDir}/${tdiStagingDir}/linux_x86_64/${tdiInstallBin}"
log "INFO: Installing TDI..."
${tdiInstall} -f ${tdiInstallResponseFile} -i silent -D\$TDI_NOSHORTCUTS\$="true"
checkStatus ${?} "ERROR: TDI installation failed. Exiting."

# Install TDI Fix Pack
log "INFO: Installing TDI fix pack..."
${cp} -f ${updateInstaller} ${tdiInstallDir}/maintenance 
${tdiInstallDir}/bin/applyUpdates.sh -update ${fixPack} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: TDI fix pack installation failed. Exiting."

# Print the results
version=$(${tdiVersion} | ${grep} "^Level" | ${cut} -d ' ' -f 2)
log "INSTALL: Success! TDI ${version} has been installed."
