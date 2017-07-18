# Get the script name
me=$(${echo} ${0} | ${awk} -F '/' '{print $(NF-1)"/"$NF}')

# This is used to give us a file descriptor to print to normal stdout since we'll be redirecting fd 1 to the script log
fd101=$(${ls} /proc/${BASHPID}/fd | ${grep} 101)
if [ -z ${fd101} ]; then
    exec 101>&1
fi

# Reset the file descriptors for normal output
function resetOutput() {
    exec 1>&101 2>&1
}

# Redirect the file descriptors for script output
function redirectOutput() {
    exec 1>>${scriptLog} 2>&1
    # This is needed to give process substition a chance to complete before main shell continues
    sleep 1
}

# Create the logs dir if it doesn't already exist
function checkForLogDir() {
    local files
    if [ ! -d ${logDir} ]; then
        ${mkdir} -p ${logDir}
        ${chmod} a+rwx ${logDir}
        ${touch} ${scriptLog}
        ${chmod} a+w ${scriptLog}
        log "I Created log file."
    fi
}

# Tests to make sure the effective user ID is root
function checkForRoot() {
    local script=${0}
	if [ "${EUID}" -ne 0 ]; then
		log "E Script ${script} needs to run as root. Exiting."
		exit 1
    else
        setRootUlimit
	fi
}

# Set the ulimit for root
function setRootUlimit() {
    local currentLimit
    currentLimit=$(ulimit -n)
    logDebug "D Open file limit before modification is ${currentLimit}"
    ulimit -n ${openFileLimit}
    currentLimit=$(ulimit -n)
    logDebug "D Open file limit after modification is ${currentLimit}"
}

# Print message to stderr with date/time prefix
# $1: message to print
function log() {
    local message=${1}
    local now=$(date '+%F %T')
	printf "%s %-16.16s %s\n" "${now}" "${me}" "${message}" >&101
	printf "%s %-16.16s %s\n" "${now}" "${me}" "${message}"
}

# Print message if debug is enabled
# $1: message to print
function logDebug() {
    local message="${1}"
    if [ ${debug} == "true" ]; then
        log "${message}"
    fi
}

# Print message for the beginning/end of a component install
# $1: component being installed
# $2: begin | end
function logInstall() {
    local component=${1}
    local phase=${2}
    if [ ${phase} == 'begin' ]; then
        log "I Beginning install of [${component}]..."
    elif [ ${phase} == 'end' ]; then
        log "I Completed install of [${component}]."
    else
        log "W Unrecognized phase [${phase}] in logInstall."
    fi
}

# Print message for the beginning/end of a component uninstall
# $1: component being uninstalled
# $2: begin | end
function logUninstall() {
    local component=${1}
    local phase=${2}
    if [ ${phase} == 'begin' ]; then
        log "I Beginning uninstall of [${component}]..."
    elif [ ${phase} == 'end' ]; then
        log "I Completed uninstall of [${component}]."
    else
        log "W Unrecognized phase [${phase}] in logUninstall."
    fi
}

# Print message for the beginning/end of a component configuration
# $1: component being configured
# $2: begin | end
function logConfigure() {
    local component=${1}
    local phase=${2}
    if [ ${phase} == 'begin' ]; then
        log "I Beginning configuration of [${component}]..."
    elif [ ${phase} == 'end' ]; then
        log "I Completed configuration of [${component}]."
    else
        log "W Unrecognized phase [${phase}] in logConfigure."
    fi
}

# General-purpose routine to check exit code of previous operation.
# Failures are fatal.
# $1: exit code of previous operation
# $2: message to print if exit code is not 0
function checkStatus() {
    local code=${1}
    local message=${2}
    local severity=""
	if [ ${code} -ne 0 ]; then
        severity=$(${echo} ${message} | ${awk} '{print $1}')
		log "${message}"
        if [ ${severity} == 'E' ]; then
		    log "E Exit status: ${code}"
		    exit 1
        fi
	fi
}

# Check the exit status for child processes
# $1: child process temp directory
function checkChildProcessStatus() {
    local tempDir=${1}
    local childStatus
    if [ ! -d ${tempDir} ]; then
        log "E Child process temp directory ${tempDir} does not exist. Exiting."
        exit 1
    fi
    for i in $(${find} ${tempDir} -maxdepth 1 -type f); do
        #log "I Child process is: ${i}"
        childStatus=$(${cat} ${i})        
        checkStatus ${childStatus} "E Child process with pid ${i} completed with error. Exiting."
    done
}

# Check exit code of database operation. Per the DB2 doc, the -s option
# means an error if the exit code is not 0, 1, 2, or 3 (3 is returned
# when one or more commands result in both codes 1 and 2.
# $1: "create"|"drop"
# $2: exit code from DB2
# $3: message
function checkStatusDb() {
    local operation=${1}
    local code=${2}
    local message=${3}
    # Exit on errors when creating
    if [ ${operation} == "create" ]; then
	    if [ ${code} -ne 0 -a ${code} -ne 1 -a ${code} -ne 2 -a ${code} -ne 3 ]; then
		    log "E ${message}"
		    log "E Exit status: ${code}"
		    exit 1
	    fi
    fi
    # Continue on errors when dropping
    if [ ${operation} == "drop" ]; then
	    if [ ${code} -ne 0 -a ${code} -ne 1 -a ${code} -ne 2 ]; then
		    log "W ${message}"
	    fi
    fi
}

# Check the exit status for child processes (database creation)
# $1: operation (create|drop)
function checkChildProcessStatusDb() {
    local operation=${1}
    local childStatus
    if [ ! -d ${childProcessTempDir}/db ]; then
        log "E Child process temp directory ${childProcessTempDir}/db does not exist. Exiting."
        exit 1
    fi
    for i in $(${ls} ${childProcessTempDir}/db); do
        childStatus=$(${cat} ${childProcessTempDir}/db/${i})        
        checkStatusDb ${operation} ${childStatus} "E Child process with pid ${i} completed with error. Exiting."
    done
}

# Check status after adding/deleting user or group.
# $1: Exit code from user/group management command
# $2: Log message
# $3: User or group name
# $4: ADD | DELETE 
function checkUserGroupStatus() {
    local code=${1}
    local message=${2}
    local userOrGroup=${3}
    local operation=${4}
    if [ ${operation} == "ADD" ]; then
        if [ ${code} -ne 0 ]; then
            # Non-fatal error
            if [ ${code} -eq 9 ]; then
                log "W ${userOrGroup} already exists. Continuing..."	
            # Fatal
            else
                log "${message} ${userOrGroup}"
                log "E Exit status: ${code}"
                exit 1
            fi
        fi
    elif [ ${operation} == "DELETE" ]; then
        # Non-fatal error
        if [ ${code} -ne 0 ]; then
            log "${message} ${userOrGroup}"
        fi
    fi
}

# Test if the supplied directory exists
# $1: directory to check as proxy to see if component is installed
function isInstalled() {
    local directory="${1}"
    if [ ! -d "${directory}" ]; then
        ${echo} 1
    else
        ${echo} 0
    fi
}

# Add pam_limits.so to the following /etc/pam.d files:
# sshd
# su
# sudo
function updatePamFiles() {
    local status
	# /etc/pam.d/sshd
	${grep} "pam_limits.so" ${pamSshdFile} >/dev/null 2>&1
	status=${?}
	if [ ${status} -ne 0 ]; then
		${printf} "${pamLimits}" >>${pamSshdFile}
	else
		log "W ${pamSshdFile} already contains an entry for pam_limits.so. Manual review required."
	fi
	# /etc/pam.d/su
	${grep} "pam_limits.so" ${pamSuFile} >/dev/null 2>&1
	status=${?}
	if [ ${status} -ne 0 ]; then
		${printf} "${pamLimits}" >>${pamSuFile}
	else
		log "W ${pamSuFile} already contains an entry for pam_limits.so. Manual review required."
	fi
	# /etc/pam.d/sudo
	${grep} "pam_limits.so" ${pamSudoFile} >/dev/null 2>&1
	status=${?}
	if [ ${status} -ne 0 ]; then
		${printf} "${pamLimits}" >>${pamSudoFile}
	else
		log "W ${pamSudoFile} already contains an entry for pam_limits.so. Manual review required."
	fi
}

# Download a file from FTP
# $1: FTP directory
# $2: file name
function downloadFile() {
    local dir=${1}
    local file=${2}
    log "I Downloading ${file} from ${ftpServer}..."
    ${curl} ftp://${ftpServer}/${dir}/${file}
    checkStatus ${?} "E Download failed. Exiting."
}

# Download multiple files from FTP
# $1: List of files 
function downloadFiles() {
    local files="${1}"
    for i in ${files}; do
        log "I Downloading ${i}..."
    done
    ${echo} ${files} | ${xargs} -n 1 -P 8 ${curl} 
    checkStatus ${?} "E Download failed. Exiting."
}

# Unpack an archive file
# $1: file type
# $2: file name
function unpackFile() {
    local archiveType=${1}
    local file=${2}
    local result
    log "I Unpacking ${file}..."
    if [ ${archiveType} == "zip" ]; then
        ${unzip} -qq ${file}
        result=${?}
    elif [ ${archiveType} == "tar" ]; then
        ${tar} -xf ${file}
        result=${?}
    fi
    checkStatus ${result} "E Unpack operation failed. Exiting."
}

# Unpack zip archive files
# $1: List of files 
function unpackZipFiles() {
    local files=${1}
    local result
    for i in ${files}; do
        log "I Unpacking ${i}..."
    done
    ${echo} ${files} | ${xargs} -n 1 -P 8 ${unzip} -qq 
    checkStatus ${?} "E Unpack operation failed. Exiting."
}

# Unpack tar archive files
# $1: List of files 
function unpackTarFiles() {
    local files=${1}
    local result
    for i in ${files}; do
        log "I Unpacking ${i}..."
    done
    ${echo} ${files} | ${xargs} -n 1 -P 24 ${tar} -xf 
    checkStatus ${?} "E Unpack operation failed. Exiting."
}


# Unpack an archive file to the specified directory
# $1: file type
# $2: file name
# $3: directory
function unpackFileToDirectory() {
    local archiveType=${1}
    local file=${2}
    local directory=${3}
    local result
    log "I Unpacking ${file} to ${directory}..."
    if [ ${archiveType} == "zip" ]; then
        ${unzip} -qq ${file} -d ${directory}
        result=${?}
    elif [ ${archiveType} == "tar" ]; then
        ${tar} -xf ${file} --directory ${directory} --strip-components=1
        result=${?}
    fi
    checkStatus ${result} "E Unpack operation failed. Exiting."
}

# Clean up from a prior installation by recreating the
# product install staging directory
# $1: product component
function clean() {
    local productStagingDir=${1}
    ${rm} -f -r ${stagingDir}/${productStagingDir}
    ${mkdir} -p ${stagingDir}/${productStagingDir}
    checkStatus ${?} "E Unable to create ${stagingDir}/${productStagingDir}. Exiting."
}

# Create a new response file from a template
# $1: template file
# $2: new file
function copyTemplate() {
    local template=${1}
    local file=${2}
    log "I Building silent install response file..."
    ${cp} -f ${template} ${file}
    checkStatus ${?} "E Unable to copy ${template} to ${file}. Exiting."
}

# Change directory to the product staging directory
# $1: directory to cd to
function cdToProductStagingDir() {
    local directory=${1}
    cd ${directory}
}

# Give 755 access to the staging dir
function grantAccessToStagingDir() {
    ${chmod} 755 ${stagingDir}
} 

# Do initialization stuff
# $1: component being processed (e.g. db2, iim, was, tdi, etc.)
# $2: operation (e.g. install, uninstall, configure)
function init() {
    local component=${1}
    local operation=${2}
    checkForRoot
    checkForLogDir
    # If running the main install script, rotate the logs so we start fresh
    if [ ${component} == "main" -a ${operation} == "main_install" ]; then
        logRotate
    fi
    # Redirect stdout and stderr
    redirectOutput
    grantAccessToStagingDir
    # When installing components, additional tasks are required
    if [ ${operation} == "install" ]; then
        # Some components like the Connections dbs have no install directory and shouldn't be checked
        local installDir="null"
        if [ ${component} == "db2" ]; then
            installDir=${db2InstallDir}
        elif [ ${component} == "iim" ]; then
            installDir=${iimInstallDir}
        elif [ ${component} == "web" ]; then
            installDir=${webInstallDir}
        elif [ ${component} == "tdi" ]; then
            installDir=${tdiInstallDir}
        elif [ ${component} == "ic" ]; then
            installDir=${icInstallDir}
        fi
        # For installable components, check to see if it appears that the component has already been installed 
        # Skip check for Connections since each feature will be checked individually in src/ic/install.sh.
        if [ ${installDir} != "null" -a ${component} != "ic" ]; then
            local installed=$(isInstalled ${installDir})
            if [ ${installed} -eq 0 ]; then
                log "W Install directory ${installDir} already exists. Assuming ${component} is already installed. Skipping."    
                exit 0 
            fi    
        fi
    fi
    if [ ${operation} == "install" -o ${operation} == "update" ]; then
        # Recreate the staging directory
        clean ${component}
        cdToProductStagingDir ${stagingDir}/${component}
        # Recreate the child process temp directory
        resetChildProcessTempDir ${childProcessTempDir}/${component}
    fi
}

# Move live logs to archive directory
function logRotate() {
    local now=$(${date} '+%Y%m%d_%H%M%S')
    local originalDir=$(${pwd})
    # Skip if the log directory doesn't exist
    if [ -d ${logDir} ]; then
        # cd to logs dir to use relative paths for tar
        cd ${logDir}
        # Create the archive subdirectory if it doesn't already exist
        if [ ! -d ${logDir}/archive ]; then
            ${mkdir} -p ${logDir}/archive
        fi
        # Create an archive of the existing logs 
        ${find} . -maxdepth 1 -type f | ${tar} -czf ${logDir}/archive/logs_${now}.tar.gz -T -
        # Delete the live logs to prepare for the next run
        ${find} . -maxdepth 1 -type f | ${xargs} ${rm} -f
    fi
    # cd back to the original directory
    cd ${originalDir}
}

# Determine if the given server exists
# $1: server to check
# $2: profile root
# Returns 0 if the specified server exists, otherwise 1
function doesWASServerExist() {
    local server=${1}
    local profileRoot=${2}
    local node
    if [ ${server} == ${dmgrServerName} ]; then 
        node=${dmgrNodeName}
    else
        node=${ic1NodeName}
    fi
    if [ -d ${profileRoot}/config/cells/${dmgrCellName}/nodes/${node}/servers/${server} ]; then
        return 0
    else
        return 1
    fi
}

# Returns the status of the specified WAS server
# $1: server to check
# $2: profile root
# Returns "started" if the server is started, "stopped" if it is stopped, and "undefined" if any unknown state
function getWASServerStatus() {
    local server=${1}
    local profileRoot=${2}
    local serverStatus
    local result
    local functionStatus="undefined"
    doesWASServerExist ${server} ${profileRoot}
    result=${?}
    if [ ${result} -ne 0 ]; then
        log "I Server ${server} does not exist. Skipping."
        functionStatus="nonexistent"
    else
        # Get the result of the serverStatus.sh command
        serverStatus=$(${profileRoot}/bin/serverStatus.sh ${server} -username ${dmgrAdminUser} -password ${defaultPwd})
        # Check to see if the server is stopped
        ${echo} ${serverStatus} | ${grep} stopped >/dev/null 2>&1
        result=${?}
        if [ ${result} -eq 0 ]; then
            functionStatus="stopped"
        fi 
        # Check to see if the server is started
        ${echo} ${serverStatus} | ${grep} STARTED >/dev/null 2>&1
        result=${?}
        if [ ${result} -eq 0 ]; then
            functionStatus="started"
        fi
    fi
    ${echo} ${functionStatus}
}

# Start the specified WAS server
# $1: server
# $2: profile path
# Returns 0 if successful, otherwise 1
function startWASServer() {
    local server=${1}
    local profileRoot=${2}
    local serverStatus
    doesWASServerExist ${server} ${profileRoot}
    result=${?}
    if [ ${result} -ne 0 ]; then
        log "E Server ${server} does not exist."
        # Consider this a failure scenario since a nonexistent server can't be started
        return 1
    else
        serverStatus=$(getWASServerStatus ${server} ${profileRoot})
        # Only need to start the server if it's not already started
        if [ ${serverStatus} != "started" ]; then
            log "I Starting WAS server ${server}..."
            ${profileRoot}/bin/startServer.sh ${server}
            serverStatus=$(getWASServerStatus ${server} ${profileRoot})
        fi
        # Return success if the server is now started or failure if it is not
        if [ ${serverStatus} == "started" ]; then
            return 0 
        else
            return 1
        fi
    fi
}

# Stop the specified WAS server
# $1: server
# $2: profile path
# Returns 0 if successful, otherwise 1
function stopWASServer() {
    local server=${1}
    local profileRoot=${2}
    local serverStatus
    doesWASServerExist ${server} ${profileRoot}
    result=${?}
    if [ ${result} -ne 0 ]; then
        log "I Server ${server} does not exist. Skipping."
        # Consider this a successful scenario since a nonexistent server is "stopped"
        return 0 
    else
        serverStatus=$(getWASServerStatus ${server} ${profileRoot})
        # Only need to stop the server if it's not already stopped
        if [ ${serverStatus} != "stopped" ]; then
            log "I Stopping WAS server ${server}..."
            ${profileRoot}/bin/stopServer.sh ${server} -username ${dmgrAdminUser} -password ${defaultPwd}
            serverStatus=$(getWASServerStatus ${server} ${profileRoot})
        fi
        # Return success if the server is now stopped or failure if it is not
        if [ ${serverStatus} == "stopped" ]; then
            return 0
        else
            return 1
        fi
    fi
}

# Restart the specified WAS server
# $1: server
# $2: profile path
# Returns 0 if successful, otherwise 1
function restartWASServer() {
    local server=${1}
    local profileRoot=${2}
    local serverStatus
    doesWASServerExist ${server} ${profileRoot}
    result=${?}
    if [ ${result} -ne 0 ]; then
        log "E Server ${server} does not exist."
        # Consider this a failure scenario since a nonexistent server cannot be restarted
        return 1
    else
        # First stop the server
        stopWASServer ${server} ${profileRoot}
        serverStatus=${?}
        # If the server couldn't be stopped, the entire operation is already a failure
        if [ ${serverStatus} -ne 0 ]; then
            return 1 
        fi 
        # Start the server
        startWASServer ${server} ${profileRoot}
        serverStatus=${?}
        if [ ${serverStatus} -ne 0 ]; then
            return 1
        else
            return 0
        fi 
    fi
}

# Restart all WAS servers and do a node resync
# Returns 0 if successful, otherwise 1
function restartAllWASServersWithNodeSync() {
    local ic1Exists
    local dmgrExists
    local nodeagentExists
    local serverStatus
    doesWASServerExist ${ic1ServerName} ${ic1ProfileDir}
    ic1Exists=${?}
    if [ ${ic1Exists} -eq 0 ]; then
        # Stop the application server
        stopWASServer ${ic1ServerName} ${ic1ProfileDir}
        serverStatus=${?}
        if [ ${serverStatus} -ne 0 ]; then
            # Return a failure if the application server could not be stopped
            return 1 
        fi
    fi
    doesWASServerExist nodeagent ${ic1ProfileDir}
    nodeagentExists=${?}
    if [ ${nodeagentExists} -eq 0 ]; then
        # Stop the node agent
        stopWASServer nodeagent ${ic1ProfileDir}
        serverStatus=${?}
        if [ ${serverStatus} -ne 0 ]; then
            # Return a failure if the node agent could not be stopped
            return 1
        fi
    fi
    doesWASServerExist ${dmgrServerName} ${dmgrProfileDir}
    dmgrExists=${?}
    if [ ${dmgrExists} -eq 0 ]; then
        # Restart the deployment manager 
        restartWASServer ${dmgrServerName} ${dmgrProfileDir}
        serverStatus=${?}
        if [ ${serverStatus} -ne 0 ]; then
            # Return a failure if the deployment manager could not be restarted
            return 1
        fi
    fi
    if [ ${dmgrExists} -eq 0 -a ${nodeagentExists} -eq 0 ]; then
        # Sync the node 
        syncWASNode
        serverStatus=${?}
        if [ ${serverStatus} -ne 0 ]; then
            return 1
        fi
    fi
    if [ ${ic1Exists} -eq 0 ]; then
        # Then start the application server (node agent is restarted as part of the sync operation)
        startWASServer ${ic1ServerName} ${ic1ProfileDir}
        serverStatus=${?}
        if [ ${serverStatus} -ne 0 ]; then
            return 1
        fi
    fi
    # Success
    return 0
}

# Perform a node resync
# Returns 0 if successful, otherwise 1
function syncWASNode() {
    local dmgrExists
    local nodeagentExists
    local ic1Exists
    local serverStatus
    doesWASServerExist ${dmgrServerName} ${dmgrProfileDir}
    dmgrExists=${?}
    doesWASServerExist nodeagent ${ic1ProfileDir}
    nodeagentExists=${?}
    doesWASServerExist ${ic1ServerName} ${ic1ProfileDir}
    ic1Exists=${?}
    if [ ${dmgrExists} -ne 0 -o ${nodeagentExists} -ne 0 ]; then
        # Don't return an error here since a resync isn't necessary
        log "W The deployment manager and/or node agent do not exist. No resync required."
    else
        # Make sure the deployment manager is running
        startWASServer ${dmgrServerName} ${dmgrProfileDir}
        serverStatus=${?}
        if [ ${serverStatus} -ne 0 ]; then
            return 1 
        fi
        # Do the sync (this also stops the node agent and application server and restarts the node agent upon completion)
        serverStatus=$(${ic1ProfileDir}/bin/syncNode.sh ${dmgrFqdn} -stopservers -restart -username ${dmgrAdminUser} -password ${defaultPwd})
        # Check to see if the sync was successful
        ${echo} ${serverStatus} | ${grep} "has been synchronized" >/dev/null 2>&1
        serverStatus=${?}
        # If synchronization failed, return an error
        if [ ${serverStatus} -ne 0 ]; then
            return 1
        # If synchronization succeeded, start the application server, if necessary
        else
            if [ ${ic1Exists} -eq 0 ]; then
                startWASServer ${ic1ServerName} ${ic1ProfileDir}
                serverStatus=${?}
                # If the application server couldn't be started, return an error
                if [ ${serverStatus} -ne 0 ]; then
                    return 1
                fi
            fi
        fi 
    fi
    # If no errors, return success
    return 0
}

# Start IHS server
function startIHSServer() {
    local serverStatus
    log "I Starting IHS server..."
    ${ihsInstallDir}/bin/apachectl -k start
    serverStatus=${?}
    if [ ${serverStatus} -ne 0 ]; then
        return 1 
    else
        return 0
    fi
}

# Stop IHS server
function stopIHSServer() {
    local serverStatus
    log "I Stopping IHS server..."
    ${ihsInstallDir}/bin/apachectl -k stop
    sleep 3
    # Kill remaining processes
    ${ps} -ef | ${grep} ${ihsInstallDir} | ${grep} -v 'grep' | ${awk} '{print $2}' | ${xargs} -r ${kill} -9
    return 0
}

# Restart IHS server
function restartIHSServer() {
    local serverStatus
    log "I Restarting IHS server..."
    ${ihsInstallDir}/bin/apachectl -k restart
    serverStatus=${?}
    if [ ${serverStatus} -ne 0 ]; then
        return 1 
    else
        return 0 
    fi 
}

# Reset the child process temp directory
# $1: child process temp directory
function resetChildProcessTempDir() {
    local tempDir=${1}
    if [ -d ${tempDir} ]; then
        ${find} ${tempDir} -maxdepth 1 -type f -delete
    fi
    ${mkdir} -p ${tempDir}
}
