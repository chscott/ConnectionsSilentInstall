me=$(${echo} ${0} | ${awk} -F '/' '{print $(NF-1)"/"$NF}')

# Saved original stdout and stderr
exec 3>&1
exec 4>&2

# Create the logs dir if it doesn't already exist
function checkForLogDir() {

    if [ ! -d ${logDir} ]; then
        ${mkdir} ${logDir}
        ${chmod} a+rwx ${logDir}
        ${touch} ${scriptLog}
        ${chmod} a+w ${scriptLog}
        log "I Created log file."
    fi

}

# Reset stdout and stderr
function resetOutput() {

    exec 1>&3
    exec 2>&4

}

# Tee output to script log
function redirectOutput() {

    resetOutput
    checkForLogDir
    exec 1> >(tee -a ${scriptLog}) 2>&1
    # This is needed to give process substition a chance to complete before main shell continues
    sleep 1

}

# Tests to make sure the effective user ID is root
function checkForRoot() {

    local script=${0}

	if [ "${EUID}" -ne 0 ]; then
		log "E Script ${script} needs to run as root. Exiting."
		exit 1
	else
		log "I Script ${script} is running as root. Continuing..."
	fi

}

# Print message to stderr with date/time prefix
# $1: message to print
function log() {

    local message=${1}
    local now=$(date '+%F %T')

	printf "%s %-16.16s %s\n" "${now}" "${me}" "${message}" >&2

}

# General-purpose routine to check exit code of previous operation.
# Failures are fatal.
# $1: exit code of previous operation
# $2: message to print if exit code is not 0
function checkStatus() {

    local code=${1}
    local message=${2}

	if [ ${code} -ne 0 ]; then
		log "${message}"
		log "E Exit status: ${code}"
		exit 1
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
        log "I Child process is: ${i}"
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

    local directory=${1}

    if [ ! -d ${directory} ]; then
        echo 1
    else
        echo 0
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
		${printf} "${pamLimits}" >> ${pamSshdFile}
	else
		log "W ${pamSshdFile} already contains an entry for pam_limits.so. Manual review recommended."
	fi

	# /etc/pam.d/su
	${grep} "pam_limits.so" ${pamSuFile} >/dev/null 2>&1
	status=${?}
	if [ ${status} -ne 0 ]; then
		${printf} "${pamLimits}" >> ${pamSuFile}
	else
		log "W ${pamSuFile} already contains an entry for pam_limits.so. Manual review recommended."
	fi

	# /etc/pam.d/sudo
	${grep} "pam_limits.so" ${pamSudoFile} >/dev/null 2>&1
	status=${?}
	if [ ${status} -ne 0 ]; then
		${printf} "${pamLimits}" >> ${pamSudoFile}
	else
		log "W ${pamSudoFile} already contains an entry for pam_limits.so. Manual review recommended."
	fi

}

# Download a file from FTP
# $1: FTP directory
# $2: file name
function downloadFile() {

    local dir=${1}
    local file=${2}

    log "I Downloading ${file} from ${ftpServer}..."
    ${curl} ftp://${ftpServer}/${dir}/${file} >>${scriptLog}
    checkStatus ${?} "E Download failed. Exiting."

}

# Download multiple files from FTP
# $1: List of files 
function downloadFiles() {

    local files="${1}"

    for i in ${files}; do
        log "I Downloading ${i}..."
    done

    echo ${files} | ${xargs} -n 1 -P 8 ${curl} >>${scriptLog} 2>&1 
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

    echo ${files} | ${xargs} -n 1 -P 8 ${unzip} -qq >>${scriptLog} 2>&1 

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

    echo ${files} | ${xargs} -n 1 -P 24 ${tar} -xf >>${scriptLog} 2>&1 

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
    fi

    checkStatus ${result} "E Unpack operation failed. Exiting."

}

# Clean up from a prior installation by recreating the
# product install staging directory
# $1: product component
function clean() {

    local installStagingDir=${1}

    log "I Recreating product install staging directory..."
    ${rm} -f -r ${stagingDir}/${installStagingDir}
    ${mkdir} -p ${stagingDir}/${installStagingDir}
    checkStatus ${?} "E Unable to create ${stagingDir}/${installStagingDir}. Exiting."

}

# Create a new response file from a template
# $1: template file
# $2: new file
function copyTemplate() {
    
    local template=${1}
    local file=${2}

    log "I Building silent install response file..."

    ${cp} ${template} ${file}
    checkStatus ${?} "E Unable to copy ${template} to ${file}. Exiting."

}

# Change directory to the product staging directory
# $1: directory to cd to
function cdToStagingDir() {
    
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

    # Skip redirection for main script to avoid duplicated log lines
    if [ ${component} != "main" ]; then
        redirectOutput
    fi

    checkForRoot
    grantAccessToStagingDir
    checkForLogDir    

    # When installing components, additional tasks are required
    if [ ${operation} == "install" ]; then

        # Some components like the Connections dbs have no install directory and shouldn't be checked
        local installDir="null"

        if [ ${component} == ${db2StagingDir} ]; then
            installDir=${db2InstallDir}
        elif [ ${component} == ${iimStagingDir} ]; then
            installDir=${iimInstallDir}
        elif [ ${component} == ${webStagingDir} ]; then
            installDir=${webInstallDir}
        elif [ ${component} == ${tdiStagingDir} ]; then
            installDir=${tdiInstallDir}
        elif [ ${component} == ${icStagingDir} ]; then
            installDir=${icInstallDir}
        fi

        # For installable components, check to see if it appears that the component has already been installed 
        if [ ${installDir} != "null" ]; then
            local installed=$(isInstalled ${installDir})
            if [ ${installed} -eq 0 ]; then
                log "E Install directory ${installDir} already exists. Assuming ${component} is already installed. Exiting."    
                exit 1
            fi    
        fi

        # Recreate the staging directory
        clean ${component}
        cdToStagingDir ${component}

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
            ${mkdir} ${logDir}/archive
        fi

        # Create an archive of the existing logs 
        ${find} . -maxdepth 1 -type f | ${tar} -czf ${logDir}/archive/logs_${now}.tar.gz -T -

        # Delete the live logs to prepare for the next run
        ${find} . -maxdepth 1 -type f | ${xargs} ${rm} -f
    fi

    # cd back to the original directory
    cd ${originalDir}

}

# Returns the status of the specified WAS server
# $1: server to check
# $2: profile root
function getWASServerStatus() {

    local server=${1}
    local profileRoot=${2}
    local serverStatus
    local result
    local functionStatus="undefined"

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

    echo ${functionStatus}

}

# Start the specified WAS server
# $1: server
# $2: profile path
function startWASServer() {

    local server=${1}
    local profileRoot=${2}
    local serverStatus
    local functionStatus

    serverStatus=$(getWASServerStatus ${server} ${profileRoot})

    # Only need to start the server if it's not already started
    if [ ${serverStatus} != "started" ]; then
        log "I Starting ${server}..."
        ${profileRoot}/bin/startServer.sh ${server} >>${scriptLog} 2>&1
        serverStatus=$(getWASServerStatus ${server} ${profileRoot})
    fi

    # Return success if the server is now started or failure if it is not
    if [ ${serverStatus} == "started" ]; then
       functionStatus=0
    else
       functionStatus=1
    fi

    echo ${functionStatus}

}

# Stop the specified WAS server
# $1: server
# $2: profile path
function stopWASServer() {

    local server=${1}
    local profileRoot=${2}
    local serverStatus
    local functionStatus

    serverStatus=$(getWASServerStatus ${server} ${profileRoot})

    # Only need to stop the server if it's not already stopped
    if [ ${serverStatus} != "stopped" ]; then
        log "I Stopping ${server}..."
        ${profileRoot}/bin/stopServer.sh ${server} -username ${dmgrAdminUser} -password ${defaultPwd} >>${scriptLog} 2>&1
        serverStatus=$(getWASServerStatus ${server} ${profileRoot})
    fi

    # Return success if the server is now stopped or failure if it is not
    if [ ${serverStatus} == "stopped" ]; then
       functionStatus=0
    else
       functionStatus=1
    fi

    echo ${functionStatus}

}

# Restart the specified WAS server
# $1: server
# $2: profile path
function restartWASServer() {

    local server=${1}
    local profileRoot=${2}
    local serverStatus
    local functionStatus

    # First stop the server
    serverStatus=$(stopWASServer ${server} ${profileRoot})
    if [ ${serverStatus} -ne 0 ]; then
        functionStatus=1
    else
        functionStatus=0
    fi 

    # Only proceed if the server stop didn't fail
    if [ ${functionStatus} -eq 0 ]; then
        # Start the server
        serverStatus=$(startWASServer ${server} ${profileRoot})
        if [ ${serverStatus} -ne 0 ]; then
            functionStatus=1
        else
            functionStatus=0
        fi 
    fi

    echo ${functionStatus}

}

# See if WAS server is running
# $1: server name
# $2: profile directory
function isWASServerRunning() {

    local server=${1}
    local profile=${2}
    local functionStatus

    result=$(getWASServerStatus ${server} ${profile})
    if [ ${result} == "started" ]; then
        functionStatus=0
    else
        functionStatus=1 
    fi

    echo ${functionStatus}

}

# Start IHS Admin server
function startIHSAdminServer() {

    local serverStatus
    local functionStatus

    log "I Starting IHS administration server..."
    ${ihsInstallDir}/bin/adminctl start >>${scriptLog} 2>&1
    serverStatus=${?}

    if [ ${serverStatus} -ne 0 ]; then
        functionStatus=1
    else
        functionStatus=0
    fi

    echo ${functionStatus}

}

# Start IHS server
function startIHSServer() {

    local serverStatus
    local functionStatus

    log "I Starting IHS server..."

    ${ihsInstallDir}/bin/apachectl start >>${scriptLog} 2>&1
    serverStatus=${?}

    if [ ${serverStatus} -ne 0 ]; then
        functionStatus=1
    else
        functionStatus=0
    fi

    echo ${functionStatus}

}

# Stop IHS server
function stopIHSServer() {

    local serverStatus
    local functionStatus

    log "I Stopping IHS server..."

    ${ihsInstallDir}/bin/apachectl stop >>${scriptLog} 2>&1
    serverStatus=${?}

    if [ ${serverStatus} -ne 0 ]; then
        functionStatus=1
    else
        functionStatus=0
    fi

    echo ${functionStatus}

}

# Restart IHS server
function restartIHSServer() {

    local serverStatus
    local functionStatus

    log "I Restarting IHS server..."
    
    ${ihsInstallDir}/bin/apachectl restart >>${scriptLog} 2>&1
    serverStatus=${?}

    if [ ${serverStatus} -ne 0 ]; then
        functionStatus=1
    else
        functionStatus=0
    fi 

    echo ${functionStatus}

}

# Reset the child process temp directory
# $1: child process temp directory
function resetChildProcessTempDir() {

    local tempDir=${1}

    log "I Resetting child process temp directory ${tempDir}..."

    if [ -d ${tempDir} ]; then
        ${find} ${tempDir} -maxdepth 1 -type f -delete
    fi

    ${mkdir} -p ${tempDir}

}