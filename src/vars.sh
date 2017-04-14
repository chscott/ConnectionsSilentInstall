#!/bin/bash

# FTP
ftpServer="cs-ftp.swg.usma.ibm.com"                         # Host name or IP address of FTP server hosting download files
db2InstallPackage="v11.1.1fp1_linuxx64_server_t.tar.gz"     # DB2 installation package on FTP
db2LicensePackage="DB2_AESE_AUSI_Activation_11.1.zip"       # DB2 license package on FTP

# DB2
db2StagingDir="db2"                                         # DB install working directory (subdirectory of main install script
db2StagingSubDir="server_t"                                 # Depends on install package: server_t, nse, universal, nlpack, etc.  
db2InstallDir="/opt/ibm/db2"                                # Location where DB2 will be installed
db2InstanceGroup="db2iadm1"                                 # Group for instance owners
db2FencedGroup="db2fsdm1"                                   # Group for fenced users
db2DASGroup="dasadm1"                                       # Group for DAS users 
db2InstanceUser="db2inst1"                                  # Instance owner for the instance created during installation
db2FencedUser="db2fenc1"                                    # Fenced user
db2DASUser="dasusr1"                                        # DAS user
db2InstanceName=${db2InstanceUser}                          # Name of instance created during installation

# IIM

