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
configuration will run all components on a minimum number of hosts. The administrator's tasks will be reduced to downloading
the applicable installation packages and running a single install script, after which a fully functional Connections 
deployment is available for use.

## Prerequisites

1. ConnectionsSilentInstall is currently supported only on Linux. Testing has been against Red Hat Linux 7.3.

2. Installation packages for the required install components. See src/vars.sh for more information.

## Quick Start Guide

1. Download the project zip file to your system and extract rsp/ and src/ into a staging directory. For example,
   /var/tmp/staging.
	
2. Open src/misc/vars.sh and inspect the variables in the Must Review section. The variables in this section are likely (but
   not required) to need modification to match the environment. Variables in the Acceptable Defaults section may also 
	be reviewed but are unlikely to require modification.
	
3. Once src/misc/vars.sh has been reviewed and modified to match the environment, run the src/main/install.sh script to begin the
   install process. Note that you must run the script with root as the effective user ID. This means either switching to
	the root account or, more likely, running the script via sudo. For example: 
	
	```Bash
	sudo src/install.sh
	```

4. Review the output and log files during and after installation. Assuming no errors, you should be able to open a browser
   and connect to https://<your_system>/files.

## What currently works

The following functionality is currently working:

- Install package retrieval from FTP

- DB2 installation with associated configuration

- Connections database creation

- TDI installation (with fix pack)

- IIM installation

- WAS, IHS, Plug-ins and WCT installation (with fix pack)

- IHS SSL configuration

- Dmgr profile creation

- LDAP repository configuration and link to realm

- Web server plug-in definition

- Connections application server profile creation

- Connections installation (core apps plus CCM)

- Uninstall of all components (individually or collectively)

## What does not currently work

The following functionality has not yet been implemented:

- Installation of OrientMe and additional add-ons

- Profile population