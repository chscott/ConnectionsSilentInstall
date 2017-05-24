#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.sh

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
ihsSSLFragment="${stagingDir}/${webStagingDir}/ihs_ssl_config.frg"
ihsConfFile="${ihsInstallDir}/conf/httpd.conf"

log "I Beginning SSL configuration for IHS..."

# Do initialization stuff
init ${webStagingDir} configure

# Stop IHS
ihsStatus=$(stopIHSServer)
checkStatus ${ihsStatus} "E Unable to stop IHS server. Exiting."

# Create the key database
log "I Creating IHS key database..."
${keyTool} -keydb -create \
    -db ${keyDb} \
    -pw ${defaultPwd} \
    -type ${keyDbType} \
    -expire ${keyDbExpiration} \
    -stash >>${scriptLog} 2>&1
checkStatus ${?} "E Unable to create IHS key database. Exiting."
 
# Create the self-signed certificate
log "I Creating self-signed certificate..."
${keyTool} -cert -create \
    -db ${keyDb} \
    -pw ${defaultPwd} \
    -dn ${keyDn} \
    -label ${fqdn} \
    -size ${keySize} \
    -sigalg ${keyAlgorithm} \
    -default_cert yes \
    -expire ${keyExpiration} >>${scriptLog} 2>&1
checkStatus ${?} "E Unable to create self-signed certificate. Exiting."

# Update the IHS configuration
${cp} ${ihsSSLTemplate} ${ihsSSLFragment}
checkStatus ${?} "E Unable to copy ${ihsSSLTemplate} to ${ihsSSLFragment}. Exiting."
${sed} -i "s|SERVER_NAME|${fqdn}|" ${ihsSSLFragment}
${sed} -i "s|KEYDB_FILE|${keyDb}|" ${ihsSSLFragment}
${sed} -i "s|STASH_FILE|${stashFile}|" ${ihsSSLFragment}
${sed} -i "/End of example SSL configuration/ r ${ihsSSLFragment}" ${ihsConfFile} 

# Start IHS
ihsStatus=$(startIHSServer)
checkStatus ${ihsStatus} "E Unable to start IHS server. Exiting."

# Print the results
log "I Success! SSL has been enabled for IHS."
