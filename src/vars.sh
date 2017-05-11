#!/bin/bash

# This file defines global variables used for the Connections silent install.
# Variables are divided into two sections: Must Review and Acceptable Defaults.
# Any items in the Must Review section are likely to need modification to 
# match the target environment. Items in the Acceptable Defaults section are
# expected to work as suitable defaults for any target environment but can
# optionally be changed if desired.

###############################################################################
# Must Review

# Any installed components that require a password will be given this one
defaultPwd="password"
# Host name of FTP server used to download install files
ftpServer="cs-ftp.swg.usma.ibm.com"
# DB2 installation package
db2InstallPackage="v11.1.1fp1_linuxx64_server_t.tar.gz"
# DB2 install package type (see the label before .tar.gz in install package)
db2StagingSubDir="server_t"
# DB2 license package
db2LicensePackage="DB2_AESE_AUSI_Activation_11.1.zip"
# IIM install package
iimInstallPackage="agent.installer.linux.gtk.x86_64_1.8.5001.20161016_1705.zip"
# WebSphere base install packages
wasBasePackage_1="WASND_v8.5.5_1of3.zip"
wasBasePackage_2="WASND_v8.5.5_2of3.zip"
wasBasePackage_3="WASND_v8.5.5_3of3.zip"
# WebSphere supplements install packages
wasBaseSupplPackage_1="WAS_V8.5.5_SUPPL_1_OF_3.zip" 
wasBaseSupplPackage_2="WAS_V8.5.5_SUPPL_2_OF_3.zip"
wasBaseSupplPackage_3="WAS_V8.5.5_SUPPL_3_OF_3.zip"
# WebSphere fix pack install packages
wasFixPackPackage_1="8.5.5-WS-WAS-FP0000010-part1.zip"
wasFixPackPackage_2="8.5.5-WS-WAS-FP0000010-part2.zip"
# WebSphere supplements fix pack install packages
wasFixPackSupplPackage_1="8.5.5-WS-WASSupplements-FP0000010-part1.zip"
wasFixPackSupplPackage_2="8.5.5-WS-WASSupplements-FP0000010-part2.zip"
# WebSphere toolbox fix pack install packages
wasFixPackWCTPackage_1="8.5.5-WS-WCT-FP0000010-part1.zip"
wasFixPackWCTPackage_2="8.5.5-WS-WCT-FP0000010-part2.zip"
# TDI install package
tdiBasePackage="TDI_IDENTITY_E_V7.1.1_LIN-X86-64.tar"
# TDI fix pack install package
tdiFixPackPackage="7.1.1-TIV-TDI-FP0006.zip"
# Connections DB package
icDbPackage="Connections_6.0_Wizards_lin_aix.tar"
# LDAP type for Deployment Manager
# See -ldapServerType option in createIdMgrLDAPRepository WAS help doc for
# available options. Examples: AD, IDS, DOMINO, SUNONE.
ldapType="AD"
# LDAP identifier string
# See -id option in createIdMgrLDAPRepository WAS help doc for details. This
# is an arbitrary string to define the LDAP repository.
ldapId="ACTIVE_DIRECTORY"
# LDAP server host name
ldapHost="ldap.swg.usma.ibm.com"
# Port to use for LDAP communication
ldapPort="389"
# DN used to bind to LDAP
ldapBindDn="cn=ldapbind,ou=ic,dc=ad,dc=com"
# Password for Bind DN
ldapBindPwd="Passw0rd"
# Base DN for LDAP entities
ldapBase="ou=ic,dc=ad,dc=com"
# LDAP attributes used for login
loginProperties="uid;mail"
###############################################################################

###############################################################################
# Acceptable defaults

# Do not change this unless you understand exactly why you are doing so
stagingDir=$(pwd)
# Do not change this unless you understand exactly why you are doing so
hostName=$(${hostname})
# Do not change this unless you understand exactly why you are doing so
dnsSuffix=$(${hostname} -d)
# Do not change this unless you understand exactly why you are doing so
fqdn="${hostName}.${dnsSuffix}"
# Set true to install DB2 or false to skip it
installDb2="true"
# Set true to install IIM or false to skip it
installIim="true"
# Set true to install WAS or false to skip it
installWas="true"
# Set true to install IHS or false to skip it
installIhs="true"
# Set true to install Plugins or false to skip it
installPlg="true"
# Set true to install WCT or false to skip it
installWct="true"
# Set true to install TDI or false to skip it
installTdi="true"
# Set true to use FTP to download install files or false if files are local 
useFtp="true"
# Directory for all log files
logDir="${stagingDir}/logs"
# Log file for the script's stdout and stderr
scriptLog="${logDir}/script.log"                                            
# Install root for installed components
optIbmRoot="/opt/IBM"
# Data root for installed components
varIbmRoot="/var/IBM"
# System shared library directory
sysSharedLibDir="/etc/ld.so.conf.d"
# DB2 install staging directory
db2StagingDir="db2"
# Location where DB2 will be installed 
db2InstallDir="${optIbmRoot}/db2"
# Group for instance owners
db2InstanceGroup="db2iadm1"
# Group for fenced users
db2FencedGroup="db2fsdm1"
# Group for DAS users
db2DASGroup="dasadm1"
# Owner of instance created during installation
db2InstanceUser="db2inst1"
# Fenced user
db2FencedUser="db2fenc1"
# DAS user
db2DASUser="dasusr1"
# Name of instance created during installation
db2InstanceName=${db2InstanceUser}
# IIM install staging directory
iimStagingDir="iim" 
# Location where IIM will be installed
iimInstallDir="${optIbmRoot}/iim"
# Location of IIM agent data
iimDataDir="${varIbmRoot}/iim"
# Location of IIM shared resources
iimSharedDataDir="${varIbmRoot}/iim_shared"
# WAS install staging directory
wasStagingDir="was"
# Directory into which WAS base install packages will be unpacked 
wasBaseStagingDir="was_base"
# Directory into which WAS supplements install packages will be unpacked
wasBaseSupplStagingDir="was_base_suppl"
# Directory into which WAS fix pack install packages will be unpacked
wasFixPackStagingDir="was_fp"
# Directory into which WAS supplements fix pack packages will be unpacked
wasFixPackSupplStagingDir="was_fp_suppl"
# Directory into which WAS toolbox fix pack packages will be unpacked
wasFixPackWCTStagingDir="was_fp_wct"
# Location where WebSphere components will be installed
websphereInstallDir="${optIbmRoot}/websphere"
# Data directory for WebSphere components
websphereDataDir="${varIbmRoot}/websphere"
# WAS install subdirectory
wasInstallDir="${websphereInstallDir}/was"
# WAS data directory
wasDataDir="${websphereDataDir}/was"
# IHS install subdirectory
ihsInstallDir="${websphereInstallDir}/ihs"
# Plugins install subdirectory
plgInstallDir="${websphereInstallDir}/plugins"
# Toolbox install subdirectory
wctInstallDir="${websphereInstallDir}/toolbox"
# Profile name for Deployment Manager
dmgrProfileName="dmgr"
# Profile directory for Deployment Manager
dmgrProfilePath="${wasDataDir}/profiles/${dmgrProfileName}"
# Node name for Deployment Manager
dmgrNodeName="dmgr1"
# Cell name for Deployment Manager
dmgrCellName="icCell"
# Server name for Deployment Manager
dmgrServerName="dmgr"
# Profile name for Connections
icProfileName="ic"
# Profile directory for Connections
icProfilePath="${wasDataDir}/profiles/${icProfileName}"
# Node name for Connections
icNodeName="ic1"
# WAS admin user
dmgrAdminUser="wasadmin"
# WAS realm name
realmName="defaultWIMFileBasedRealm"
# TDI install staging directory
tdiStagingDir="tdi"
# Location where TDI will be installed
tdiInstallDir="/opt/IBM/tdi"
# Connections staging directory
icStagingDir="ic"
# Connections database staging directory (subdirectory of icStagingDir)
icDbStagingDir="db"
# IHS admin group (OS)
ihsAdminGroup="ihsadmins"
# IHS admin user (OS)
ihsAdmin="ihsadmin"

###############################################################################
