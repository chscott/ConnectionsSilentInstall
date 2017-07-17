## Overview

The ConnectionsSilentInstall project aims to automate a full Connections deployment, minimizing or even eliminating manual
installation and configuration steps that cause Connections to take a long time to deploy. Goals for this project include:

  - Installation and configuration of a WebSphere Application Server (WAS) cell for Connections WAS components
  - Installation of the Connections WAS components
  - Installation of IBM HTTP Server (IHS)
  - Installation of the IHS web server plug-ins
  - Installation of the WebSphere Toolbox Configuration component
  - Optional installation of DB2 as the Connections database
  - Installation of the OrientMe components
  
Connections deployments come in all shapes and sizes, and the project should accommodate as many common architectures as 
possible. The initial versions will focus on a turn-key configuration suitable for Test or Deployment environments. This
configuration will run all components on a minimum number of hosts. The administrator's tasks will be reduced to downloading the applicable installation packages and running a single install script, after which a fully functional Connections deployment is available for use.

## Prerequisites

1. ConnectionsSilentInstall is currently supported only on Linux. Testing has been against Red Hat Linux 7.3.

2. Installation packages for the required install components. See src/misc/vars.conf for more information.

## Quick Start Guide

1. Download the project zip file to your system and extract rsp/ and src/ into a staging directory. For example,
   /var/tmp/staging.
	
2. Open src/misc/vars.conf and inspect the variables. Some variable values will depend on your environment and should be
   modified accordingly. Many contain default values that should work in most cases.
	
3. Once src/misc/vars.conf has been reviewed and modified to match the environment, run the src/main/install.sh script to   
   begin the install process. Note that you must run the script with root as the effective user ID. This means either switching to the root account or, more likely, running the script via sudo. For example: 
	
	```Bash
	sudo src/main/install.sh
	```

4. Review the output and log files during and after installation. Assuming no errors, you should be able to open a browser
   and connect to https://<your_system>/files.

## What currently works

The following functionality is currently working:

- Install package retrieval from FTP

- DB2 installation with associated configuration

- Connections database creation

- TDI installation (with fix pack)

- TDI profiles population

- IIM installation

- WAS, IHS, Plug-ins and WCT installation (with fix pack)

- IHS SSL configuration

- Dmgr profile creation

- LDAP repository configuration and link to realm

- Web server plug-in definition

- Connections application server profile creation

- Connections installation (core apps plus CCM)

- CCM configuration

- Update to Java 8 SDK

- Connections fixes installation

- Uninstall of all components (individually or collectively)

## What does not currently work

The following functionality has not yet been implemented:

- Installation of OrientMe and additional add-ons

## Installation Guide

This guide assumes you are using Red Hat Enterprise Linux 7.3. Results on other distros/versions may vary.

1. Log into your system as a user with sudo privilege and create a staging directory from which you will perform the            installation. The staging directory must be relatively short to prevent errors when installing DB2 caused by a long
   path name. As a recommendation, use /var/tmp/staging, which is known to work.

    ```Bash
    ? mkdir -p /var/tmp/staging
    ? cd /var/tmp/staging
    ? pwd
    /var/tmp/staging
    ```

2. Download the installation package from GitHub.

    ```Bash
    ? curl -s -L -o master.zip https://github.com/chscott/ConnectionsSilentInstall/archive/master.zip
    ? ls
    master.zip
    ```
3. Unzip the installation package.

    ```Bash
    ? unzip -qq master.zip
    ? ls
    ConnectionsSilentInstall-master  master.zip
    ```
    
4. Move the rsp/ and src/ directories to /var/tmp/staging.

    ```Bash
    ? mv ConnectionsSilentInstall-master/rsp /var/tmp/staging
    ? mv ConnectionsSilentInstall-master/src /var/tmp/staging
    ```
    
5. Make the script files executable.

    ```Bash
    ? chmod -R u+x src/*
    ```
    
6. Edit src/misc/vars.conf for your environment. This file contains the configuration variables that define how Connections
   and related components will be installed.
   
   * The General section defines the components that will be installed. You can install various combinations of components
     to suit a wide range of topologies. For example, you may want DB2 to run on its own system. In that case, you'd set
     installDb2 to "true" and leave the remaining components set to "false". Note that some components have prerequisites
     that must be installed. To install Connections, you must also install WebSphere components. Dependencies are explained
     in the comments in this section. The defaultPwd variable is of particular importance, as every password used during
     the installation will be set to this value.
     
   * The FTP variables section identifies the FTP server and directories from which the installation files will be obtained.
     Currently, FTP is the only supported way to obtain the installation files. Set up an anonymous FTP server and put the
     installation files in the appropriate subdirectories.
     
   * The LDAP section contains details about your user repository. Change these as needed.
     
   * Each component to be installed contains a section with variables that apply to that component. At a minimum, you'll
     need to change the *Fqdn variables to match the fully qualified domain name for the system hosting that component.
     
7. After you've made all configuration changes to src/misc/vars.conf, run sudo src/main/install.sh to perform the              installation. The install can take up to several hours if you are installing all components. Progress information is        printed to the console, and detailed information can be found in log files in the directory defined by the logDir            variable in src/misc/vars.sh.

   When installing DB2, it is very likely that the install will fail due to missing prerequisites. In that case, review
   the indicated log files for missing system packages and install those packages using standard OS tools. Once the missing
   packages are installed, re-run src/main/install.sh. Tip: do a grep of the db2prereqs.rpt log file for DBT3514W. Examples
   for packages you may need to install:
   
   ```Bash
   ? sudo yum install libstdc++.so.6
   ? sudo yum install pam.i686
   ? sudo yum install ksh
   ? sudo yum install perl-Sys-Syslog
   ```
   
8. If you choose to install Connections with the CCM component, note that the script will invoke the createGCD and 
   createObjectStore configuration scripts. These require real-time user input, so the main installation script will pause
   and wait for interactive at this point in the install process.