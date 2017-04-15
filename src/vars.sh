#!/bin/bash

# FTP
ftpServer="cs-ftp.swg.usma.ibm.com"                                             # Host name or IP address of FTP server hosting download files

# DB2
db2InstallPackage="v11.1.1fp1_linuxx64_server_t.tar.gz"                         # DB2 installation package
db2LicensePackage="DB2_AESE_AUSI_Activation_11.1.zip"                           # DB2 license package
db2StagingDir="db2"                                                             # DB install working directory
db2StagingSubDir="server_t"                                                     # Depends on install package: server_t, nse, universal, nlpack, etc.  
db2InstallDir="/opt/ibm/db2"                                                    # Location where DB2 will be installed
db2InstanceGroup="db2iadm1"                                                     # Group for instance owners
db2FencedGroup="db2fsdm1"                                                       # Group for fenced users
db2DASGroup="dasadm1"                                                           # Group for DAS users 
db2InstanceUser="db2inst1"                                                      # Instance owner for the instance created during installation
db2FencedUser="db2fenc1"                                                        # Fenced user
db2DASUser="dasusr1"                                                            # DAS user
db2InstanceName=${db2InstanceUser}                                              # Name of instance created during installation

# IIM
iimInstallPackage="agent.installer.linux.gtk.x86_64_1.8.5001.20161016_1705.zip" # IIM installation package
iimStagingDir="iim"                                                             # IIM install working directory
iimInstallDir="/opt/ibm/iim"                                                    # Location where IIM will be installed
iimDataDir="/var/ibm/iim"                                                       # Location of IIM agent data
iimSharedDataDir="/var/ibm/iim_shared"                                          # Location of IIM shared resources

# WAS
wasBasePackage_1="WASND_v8.5.5_1of3.zip"                                        # Base package, file 1
wasBasePackage_2="WASND_v8.5.5_2of3.zip"                                        # Base package, file 2
wasBasePackage_3="WASND_v8.5.5_3of3.zip"                                        # Base package, file 3
wasBaseSupplPackage_1="WAS_V8.5.5_SUPPL_1_OF_3.zip"                             # Base supplements package, file 1 
wasBaseSupplPackage_2="WAS_V8.5.5_SUPPL_2_OF_3.zip"                             # Base supplements package, file 2 
wasBaseSupplPackage_3="WAS_V8.5.5_SUPPL_3_OF_3.zip"                             # Base supplements package, file 3 
wasFixPackPackage_1="8.5.5-WS-WAS-FP0000010-part1.zip"                          # Fix Pack package, file 1
wasFixPackPackage_2="8.5.5-WS-WAS-FP0000010-part2.zip"                          # Fix Pack package, file 2 
wasFixPackSupplPackage_1="8.5.5-WS-WASSupplements-FP0000010-part1.zip"          # Fix Pack supplements package, file 1
wasFixPackSupplPackage_2="8.5.5-WS-WASSupplements-FP0000010-part2.zip"          # Fix Pack supplements package, file 2 
wasFixPackWCTPackage_1="8.5.5-WS-WCT-FP0000010-part1.zip"                       # Fix Pack toolbox package, file 1
wasFixPackWCTPackage_2="8.5.5-WS-WCT-FP0000010-part2.zip"                       # Fix Pack toolbox package, file 2 
wasStagingDir="was"                                                             # WAS install working directory
wasBaseStagingDir="was_base"                                                    # Directory into which WAS base packages will be unpacked
wasBaseSupplStagingDir="was_base_suppl"                                         # Directory into which WAS base supplements will be unpacked
wasFixPackStagingDir="was_fp"                                                   # Directory into which WAS fix pack will be unpacked
wasFixPackSupplStagingDir="was_fp_suppl"                                        # Directory into which WAS fix pack supplements will be unpacked
wasFixPackWCTStagingDir="was_fp_wct"                                            # Directory into which WAS fix pack toolbox will be unpacked
wasInstallDir="/opt/ibm/was"                                                    # Location where WAS will be installed
pluginsInstallDir="${wasInstallDir}/plugins"                                    # Location where WAS plugins will be installed
wctInstallDir="${wasInstallDir}/toolbox"                                    # Location where WAS toolbox will be installed

# IHS
ihsInstallDir="/opt/ibm/ihs"                                                    # Location where IHS will be installed

# General
scriptLog="${stagingDir}/script.log"                                            # Dump script stdout and stderr here
