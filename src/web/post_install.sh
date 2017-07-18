#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/web/web.conf

# Do initialization stuff
init web update 

logConfigure 'WebSphere Post-install Tasks' begin

# Enable SSL
${enableSslScript}
checkStatus ${?} "E Failed to enable SSL. Exiting."

# Create deployment manager profile
${createDmgrProfileScript}
checkStatus ${?} "E Failed to create deployment manager profile. Exiting."

# Add LDAP
${addLdapScript}
checkStatus ${?} "E Failed to add LDAP repository. Exiting."

# Define web server
${configWebServerScript} 
checkStatus ${?} "E Failed to define web server. Exiting."

# Create application server profile
${createAppSrvProfileScript} 
checkStatus ${?} "E Failed to create application server profile. Exiting."

logConfigure 'WebSphere Post-install Tasks' end 
