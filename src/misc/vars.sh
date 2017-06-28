#!/bin/bash

################################################################################
# General 
################################################################################
defaultPwd="password"
hostName=$(${hostname})
dnsSuffix=$(${hostname} -d)
fqdn="${hostName}.${dnsSuffix}"
installDb2="true"
installTdi="true"
installIim="true"
installWeb="true"
installIc="true"

################################################################################
# FTP variables 
################################################################################
useFtp="true"
ftpServer="cs-ftp.swg.usma.ibm.com"

# FTP directories hosting install files
ftpCCMDir="ccm"
ftpCognosDir="cognos"
ftpConnectionsDir="connections"
ftpDB2Dir="db2"
ftpDocsDir="docs"
ftpIIMDir="iim"
ftpPluginsDir="plugins"
ftpTDIDir="tdi"
ftpWebDir="web"

################################################################################
# Path variables  
################################################################################

# These directories are used as temporary directories during the installation
# process. The defaults should be sufficient in almost all cases. Do not change
# the stagingDir variable unless you know exactly what you're doing. Its value
# will depend on the current working directory at the time this file is sourced.
stagingDir=$(pwd)
logDir="${stagingDir}/logs"
scriptLog="${logDir}/script.log"
db2StagingDir="db2"
iimStagingDir="iim" 
webStagingDir="web"
webBaseStagingDir="web_base"
webBaseSupplStagingDir="web_base_suppl"
webFixPackStagingDir="web_fp"
webFixPackSupplStagingDir="web_fp_suppl"
webFixPackWCTStagingDir="web_fp_wct"
webJavaSDKStagingDir="sdk"
tdiStagingDir="tdi"
icStagingDir="ic"
icDbStagingDir="db"
# DB2 install package type (see the label before .tar.gz in install package)
db2StagingSubDir="server_t"

# These directories define where components are installed.
optIbmRoot="/opt/IBM"
db2InstallDir="${optIbmRoot}/db2"
tdiInstallDir="${optIbmRoot}/tdi"
iimInstallDir="${optIbmRoot}/iim"
webInstallDir="${optIbmRoot}/websphere"
wasInstallDir="${webInstallDir}/was"
ihsInstallDir="${webInstallDir}/ihs"
plgInstallDir="${webInstallDir}/plugins"
wctInstallDir="${webInstallDir}/toolbox"
icInstallDir="${optIbmRoot}/ic"
ccmInstallDir="${icInstallDir}/ccm"
ccmCEInstallDir="${ccmInstallDir}/ce"
ccmCEClientInstallDir="${ccmInstallDir}/ce_client"
ccmFNCSInstallDir="${ccmInstallDir}/fncs"

# These directories define where component data is stored.
varIbmRoot="/var/IBM"
iimDataDir="${varIbmRoot}/iim"
iimSharedDataDir="${varIbmRoot}/iim_shared"
webDataDir="${varIbmRoot}/websphere"
wasDataDir="${webDataDir}/was"
icDataDir="${varIbmRoot}/ic"
icLocalDataDir="${icDataDir}/local"
icSharedDataDir="${icDataDir}/shared"

# Directory for child process exit codes
childProcessTempDir="${stagingDir}/tmp_child"

# Shared lib directory
sysSharedLibDir="/etc/ld.so.conf.d"

################################################################################
# Package variables  
################################################################################
# DB2
db2InstallPackage="v11.1.1fp1_linuxx64_server_t.tar.gz"
db2LicensePackage="DB2_AESE_AUSI_Activation_11.1.zip"
# TDI
tdiBasePackage="TDI_IDENTITY_E_V7.1.1_LIN-X86-64.tar"
tdiFixPackPackage="7.1.1-TIV-TDI-FP0006.zip"
# IIM
iimInstallPackage="agent.installer.linux.gtk.x86_64_1.8.5001.20161016_1705.zip"
# WebSphere
webBasePackage_1="WASND_v8.5.5_1of3.zip"
webBasePackage_2="WASND_v8.5.5_2of3.zip"
webBasePackage_3="WASND_v8.5.5_3of3.zip"
webBaseSupplPackage_1="WAS_V8.5.5_SUPPL_1_OF_3.zip" 
webBaseSupplPackage_2="WAS_V8.5.5_SUPPL_2_OF_3.zip"
webBaseSupplPackage_3="WAS_V8.5.5_SUPPL_3_OF_3.zip"
webFixPackPackage_1="8.5.5-WS-WAS-FP0000010-part1.zip"
webFixPackPackage_2="8.5.5-WS-WAS-FP0000010-part2.zip"
webFixPackSupplPackage_1="8.5.5-WS-WASSupplements-FP0000010-part1.zip"
webFixPackSupplPackage_2="8.5.5-WS-WASSupplements-FP0000010-part2.zip"
webFixPackWCTPackage_1="8.5.5-WS-WCT-FP0000010-part1.zip"
webFixPackWCTPackage_2="8.5.5-WS-WCT-FP0000010-part2.zip"
webJavaSDKPackage="8.0.3.20-WS-IBMWASJAVA-Linux.zip"
# Connections
icDbPackage="Connections_6.0_Wizards_lin_aix.tar"
icInstallPackage="IBM_Connections_6.0_lin.tar"
ccmCEBasePackage="5.2.1-P8CPE-LINUX.BIN"
ccmCEFixPackPackage="5.2.1.5-P8CPE-LINUX-FP005.BIN"
ccmCEClientFixPackPackage="5.2.1.5-P8CPE-CLIENT-LINUX-FP005.BIN"
ccmFNCSBasePackage="IBM_CONTENT_NAVIGATOR-2.0.3-LINUX.bin"
ccmFNCSFixPackPackage="IBM_CONTENT_NAVIGATOR-2.0.3.8-FP008-LINUX.bin"

################################################################################
# DB2 variables  
################################################################################
db2InstanceGroup="db2iadm1"
db2FencedGroup="db2fsdm1"
db2DASGroup="dasadm1"
db2InstanceUser="db2inst1"
db2FencedUser="db2fenc1"
db2DASUser="dasusr1"
db2InstanceName=${db2InstanceUser}

################################################################################
# WebSphere variables  
################################################################################
dmgrProfileName="dmgr"
dmgrCellName="icCell"
dmgrNodeName="dmgrNode"
dmgrServerName="dmgr"
dmgrProfileDir="${wasDataDir}/profiles/${dmgrProfileName}"
webServerName="webserver1"
icClusterName="icCluster"
ic1ProfileName="ic1"
ic1NodeName="ic1Node"
ic1ServerName="ic1"
ic1ProfileDir="${wasDataDir}/profiles/${ic1ProfileName}"
icAdminUser="wasadmin"
dmgrAdminUser="wasadmin"
realmName="defaultWIMFileBasedRealm"
ihsAdminGroup="ihsadmins"
ihsAdmin="ihsadmin"

################################################################################
# LDAP variables  
################################################################################
# See -ldapServerType option in createIdMgrLDAPRepository
ldapType="AD"
# See -id option in createIdMgrLDAPRepository
ldapId="ACTIVE_DIRECTORY"
ldapHost="ldap.swg.usma.ibm.com"
ldapPort="389"
ldapBindDn="cn=ldapbind,ou=ic,dc=ad,dc=com"
ldapBindPwd="Passw0rd"
ldapBase="ou=ic,dc=ad,dc=com"
loginProperties="uid;mail"

################################################################################
# SSL variables  
################################################################################
# Organization name used for key generation
orgName="IBM"
# Country code used for key generation
countryCode="US"

################################################################################
# Misc  
################################################################################
# Batch size to use for tasks running in parallel
batchSize=1
