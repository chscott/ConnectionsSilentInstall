#!/bin/bash

# Source prereq scripts
. src/commands.sh
. src/utils.sh
. src/vars.sh

# Local variables
keyTool="${ihsInstallDir}/bin/gskcapicmd"
keyDb="${ihsInstallDir}/key.kdb"
stashFile="${ihsInstallDir}/key.sth"
keyDbType="cms"
keyDbExpiration=3650
keyDn="CN=${fqdn},O=${orgName},C=${countryCode}"
keySize=2048
keyAlgorithm="SHA256WithRSA"
keyExpiration=3650
ihsSSLTemplate="${stagingDir}/rsp/ihs_ssl_config.tmp"
ihsSSLFragment="${stagingDir}/${wasStagingDir}/ihs_ssl_config.frg"
ihsConfFile="${ihsInstallDir}/conf/httpd.conf"

# Do initialization stuff
init was configure

# Stop IHS
ihsStatus=$(stopIHSServer)
checkStatus ${ihsStatus} "ERROR: Unable to stop IHS server. Exiting."

# Create the key database
log "INFO: Creating IHS key database..."
${keyTool} -keydb -create \
    -db ${keyDb} \
    -pw ${defaultPwd} \
    -type ${keyDbType} \
    -expire ${keyDbExpiration} \
    -stash >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to create IHS key database. Exiting."
 
# Create the self-signed certificate
log "INFO: Creating self-signed certificate..."
${keyTool} -cert -create \
    -db ${keyDb} \
    -pw ${defaultPwd} \
    -dn ${keyDn} \
    -label ${fqdn} \
    -size ${keySize} \
    -sigalg ${keyAlgorithm} \
    -default_cert yes \
    -expire ${keyExpiration} >>${scriptLog} 2>&1
checkStatus ${?} "ERROR: Unable to create self-signed certificate. Exiting."

# Update the IHS configuration
${cp} ${ihsSSLTemplate} ${ihsSSLFragment}
checkStatus ${?} "ERROR: Unable to copy ${ihsSSLTemplate} to ${ihsSSLFragment}. Exiting."
${sed} -i "s|SERVER_NAME|${fqdn}|" ${ihsSSLFragment}
${sed} -i "s|KEYDB_FILE|${keyDb}|" ${ihsSSLFragment}
${sed} -i "s|STASH_FILE|${stashFile}|" ${ihsSSLFragment}
${sed} -i "/End of example SSL configuration/ r ${ihsSSLFragment}" ${ihsConfFile} 

# Start IHS
ihsStatus=$(startIHSServer)
checkStatus ${ihsStatus} "ERROR: Unable to start IHS server. Exiting."

# Print the results
log "INFO: Success! SSL has been enabled for IHS."
