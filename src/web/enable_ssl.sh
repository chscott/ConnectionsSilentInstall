#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/web/web.conf

# Do initialization stuff
init web configure

logConfigure 'Web Server SSL' begin

# Stop web server
stopIHSServer
checkStatus ${?} "E Unable to stop web server server. Exiting."

# If there are existing key files, delete them
${rm} -f ${ihsKeyDb}
${rm} -f ${ihsStashFile}
${rm} -f ${ihsCrlFile}
${rm} -f ${ihsRdbFile}

# Create the key database
log "I Creating web server key database..."
${keyTool} -keydb -create \
    -db ${ihsKeyDb} \
    -pw ${defaultPwd} \
    -type ${keyDbType} \
    -expire ${keyDbExpiration} \
    -stash
checkStatus ${?} "E Unable to create web server key database. Exiting."
 
# Create the self-signed certificate
log "I Creating self-signed certificate..."
${keyTool} -cert -create \
    -db ${ihsKeyDb} \
    -pw ${defaultPwd} \
    -dn ${keyDn} \
    -label ${ihsFqdn} \
    -size ${keySize} \
    -sigalg ${keyAlgorithm} \
    -default_cert yes \
    -expire ${keyExpiration}
checkStatus ${?} "E Unable to create self-signed certificate. Exiting."

# See if httpd.conf has already been updated, which may occur if this script is run multiple times
${grep} 'Added by Connections silent install script' ${ihsConfFile}
result=${?}
# Update the web server configuration if needed
if [ ${result} -eq 0 ]; then
    log "W Web server configuration has already been updated. Skipping."
else
    log "I Updating the web server configuration..."
    ${cp} -f ${ihsSSLTemplate} ${ihsSSLFragment}
    checkStatus ${?} "E Unable to copy ${ihsSSLTemplate} to ${ihsSSLFragment}. Exiting."
    ${sed} -i "s|SERVER_NAME|${ihsFqdn}|" ${ihsSSLFragment}
    ${sed} -i "s|KEYDB_FILE|${ihsKeyDb}|" ${ihsSSLFragment}
    ${sed} -i "s|STASH_FILE|${ihsStashFile}|" ${ihsSSLFragment}
    ${sed} -i "/End of example SSL configuration/ r ${ihsSSLFragment}" ${ihsConfFile} 
fi

# Start web server
startIHSServer
checkStatus ${?} "E Unable to start web server server. Exiting."

logConfigure 'Web Server SSL' end
