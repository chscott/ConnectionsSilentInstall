#!/bin/bash

# Source prereq scripts
. src/misc/commands.sh
. src/misc/utils.sh
. src/misc/vars.conf
. src/web/web.conf

# Do initialization stuff
init ${webStagingDir} configure 

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
${configWebServerScript} "E Failed to define web server. Exiting."

# Create application server profile
${createAppSrvProfileScript} "E Failed to create application server profile. Exiting."

logConfigure 'WebSphere Post-install Tasks' end 
