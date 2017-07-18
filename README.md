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

## Installation Guide

This guide assumes you are using Red Hat Enterprise Linux 7.3. Results on other distros/versions may vary.

1. Log into your system as a user with sudo privilege and create the staging directory from which you will perform the          installation. The staging directory must be named /var/tmp/ic_inst.

    ```Bash
    ? mkdir -p /var/tmp/ic_inst
    ? cd /var/tmp/ic_inst
    ? pwd
    /var/tmp/ic_inst
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
    
4. Move the rsp/ and src/ directories to /var/tmp/ic_inst.

    ```Bash
    ? mv ConnectionsSilentInstall-master/rsp /var/tmp/ic_inst
    ? mv ConnectionsSilentInstall-master/src /var/tmp/ic_inst
    ```
    
5. Make the script files executable.

    ```Bash
    ? chmod -R u+x /var/tmp/ic_inst/src/*
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
   
9. The general flow of the installation and approximate timing of each step is as follows:

    1. Install DB2 (>5 minutes)
    2. Create Connections databases (20 minutes if installing all Connections apps)
    3. Install TDI (<5 minutes)
    4. Populate Profiles (depends on user count)
    5. Install IIM (<1 minute)
    6. Install WebSphere components (10 minutes)
    7. WebSphere post-install tasks (10 minutes)
    8. Install Connections (90 minutes if installing all Connections apps)
    9. Connections post-install tasks (90 minutes)