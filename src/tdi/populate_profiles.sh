#!/bin/bash

# Source prereq scripts
. /var/tmp/ic_inst/src/misc/common.sh
. /var/tmp/ic_inst/src/tdi/tdi.conf

# Do initialization stuff
init tdi configure

logInstall 'Connections Profile Population' begin

if [ ${doProfilePopulation} == "true" ]; then
    # Update profiles_tdi.properties
    log "I Updating profiles_tdi.properties..."
    ${sed} -i "s|\(source_ldap_url=\).*|\1ldap:\/\/${ldapHost}:${ldapPort}|" ${profilesTdiProperties}
    ${sed} -i "s|\(source_ldap_user_login=\).*|\1${ldapBindDn}|" ${profilesTdiProperties}
    ${sed} -i "s|\(source_ldap_user_password=\).*|\1${ldapBindPwd}|" ${profilesTdiProperties}
    ${sed} -i "s|\(source_ldap_search_base=\).*|\1${ldapBase}|" ${profilesTdiProperties}
    ${sed} -i "s|\(source_ldap_search_filter=\).*|\1${ldapFilterEscaped}|" ${profilesTdiProperties}
    ${sed} -i "s|\(dbrepos_jdbc_url=\).*|\1jdbc:db2://${db2Fqdn}:50000/peopledb|" ${profilesTdiProperties}
    ${sed} -i "s|\(dbrepos_username=\).*|\1${db2InstanceUser}|" ${profilesTdiProperties}
    ${sed} -i "s|\(dbrepos_password=\).*|\1${defaultPwd}|" ${profilesTdiProperties}

    # Replace map_dbrepos_from_source.properties with one preconfigured for our LDAP
    log "I Updating map_dbrepos_from_source.properties..."
    if [ ${ldapType} == "AD" ]; then
        mapDbreposFromSourceTemplate="${stagingDir}/rsp/map_dbrepos_from_ad.properties"    
    elif [ ${ldapType} == "DOMINO" ]; then
        mapDbreposFromSourceTemplate="${stagingDir}/rsp/map_dbrepos_from_domino.properties"    
    elif [ ${ldapType} == "SDS" ]; then
        mapDbreposFromSourceTemplate="${stagingDir}/rsp/map_dbrepos_from_sds.properties"    
    elif [ ${ldapType} == "DSEE" ]; then
        mapDbreposFromSourceTemplate="${stagingDir}/rsp/map_dbrepos_from_dsee.properties"    
    fi
    ${cp} -f ${mapDbreposFromSourceTemplate} ${mapDbreposFromSourceProperties}
    checkStatus ${?} "E Unable to copy ${mapDbreposFromSourceTemplate} to ${mapDbreposFromSourceProperties}"

    # Collect the DNs
    log "I Running collect_dns.sh..."
    ${collectDns}
    checkStatus ${?} "E Failure when running ${collectDns}. Exiting."

    # Populate the DNs
    log "I Running populate_from_dn_file.sh..."
    ${populateDns}
    checkStatus ${?} "E Failure when running ${populateDns}. Exiting."
else
    log "W Profile population is not enabled in src/misc/vars.conf. Skipping."
fi

logInstall 'Connections Profile Population' end
