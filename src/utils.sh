# Saved original stdout and stderr
exec 3>&1
exec 4>&2

# Create the logs dir if it doesn't already exist
function checkForLogDir() {

    if [ ! -d ${logDir} ]; then
        ${mkdir} ${logDir}
        ${chmod} a+rwx ${logDir}
        local now=$(date '+%F %T')
	    printf "${now}\tCreated log file.\n" >${scriptLog}
        ${chmod} a+w ${scriptLog}
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

# Disables output
function silenceOutput() {

    exec 1>/dev/null 2>&1

}

# Tests to make sure the effective user ID is root
function checkForRoot() {

	if [ "${EUID}" -ne 0 ]; then
		log "ERROR: Script ${0} needs to run as root. Exiting."
		exit 1
	else
		log "INFO: Script ${0} is running as root. Continuing..."
	fi

}

# Print $1 argument to stderr with date/time prefix
function log() {

    local now=$(date '+%F %T')
	printf "${now}\t${1}\n" >&2

}

# General-purpose routine to check exit code of previous operation.
# Failures are fatal.
function checkStatus() {

	if [ $1 -ne 0 ]; then
		log "ERROR: $2"
		log "ERROR: Exit status: $1"
		exit 1
	fi

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
		    log "ERROR: ${message}"
		    log "ERROR: Exit status: ${code}"
		    exit 1
	    fi
    fi

    # Continue on errors when dropping
    if [ ${operation} == "drop" ]; then
	    if [ ${code} -ne 0 -a ${code} -ne 1 -a ${code} -ne 2 ]; then
		    log "WARNING: ${message}"
	    fi
    fi

}

# $1: Exit code from user/group management command
# $2: Log message
# $3: User or group name
# $4: ADD | DELETE 
function checkUserGroupStatus() {

    if [ $4 == "ADD" ]; then
        if [ $1 -ne 0 ]; then
            # Non-fatal error
            if [ $1 -eq 9 ]; then
                log "WARNING: $3 already exists. Continuing..."	
            # Fatal
            else
                log "ERROR: $2 $3"
                log "ERROR: Exit status: $1"
                exit 1
            fi
        fi
    elif [ $4 == "DELETE" ]; then
        # Non-fatal error
        if [ $1 -ne 0 ]; then
            log "WARNING: $2 $3"
        fi
    fi

}

# Test if the supplied directory exists
function isInstalled() {

    if [ ! -d $1 ]; then
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
	
	# /etc/pam.d/sshd
	${grep} "pam_limits.so" ${pamSshdFile} >/dev/null 2>&1
	status=${?}
	if [ ${status} -ne 0 ]; then
		${printf} "${pamLimits}" >> ${pamSshdFile}
	else
		log "INFO: ${pamSshdFile} already contains an entry for pam_limits.so. Manual review recommended."
	fi

	# /etc/pam.d/su
	${grep} "pam_limits.so" ${pamSuFile} >/dev/null 2>&1
	status=${?}
	if [ ${status} -ne 0 ]; then
		${printf} "${pamLimits}" >> ${pamSuFile}
	else
		log "INFO: ${pamSuFile} already contains an entry for pam_limits.so. Manual review recommended."
	fi

	# /etc/pam.d/sudo
	${grep} "pam_limits.so" ${pamSudoFile} >/dev/null 2>&1
	status=${?}
	if [ ${status} -ne 0 ]; then
		${printf} "${pamLimits}" >> ${pamSudoFile}
	else
		log "INFO: ${pamSudoFile} already contains an entry for pam_limits.so. Manual review recommended."
	fi

}

# Download a file from FTP
# $1: FTP directory
# $2: file name
function downloadFile() {

    local dir=${1}
    local file=${2}
    local result

    log "INFO: Downloading ${file} from ${ftpServer}..."
    
    ${curl} ftp://${ftpServer}/${dir}/${file} >>${scriptLog}
    checkStatus ${?} "ERROR: Download failed. Exiting."

}

# Unpack an archive file
# $1: file type
# $2: file name
function unpackFile() {

    local archiveType=${1}
    local file=${2}
    local result

    log "INFO: Unpacking ${file}..."

    if [ ${archiveType} == "zip" ]; then
        ${unzip} -qq ${file}
        result=${?}
    elif [ ${archiveType} == "tar" ]; then
        ${tar} -xf ${file}
        result=${?}
    fi

    checkStatus ${result} "ERROR: Unpack operation failed. Exiting."

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

    log "INFO: Unpacking ${file} to ${directory}..."

    if [ ${archiveType} == "zip" ]; then
        ${unzip} -qq ${file} -d ${directory}
        result=${?}
    fi

    checkStatus ${result} "ERROR: Unpack operation failed. Exiting."

}

# Clean up from a prior installation by recreating the
# product install staging directory
# $1: product component
function clean() {

    local installStagingDir=${1}

    log "INFO: Recreating product install staging directory..."

    ${rm} -f -r ${stagingDir}/${installStagingDir}
    ${mkdir} -p ${stagingDir}/${installStagingDir}
    checkStatus ${?} "ERROR: Unable to create ${stagingDir}/${installStagingDir}. Exiting."
    # cd ${stagingDir}/${installStagingDir}

}

# Create a new response file from a template
# $1: template file
# $2: new file
function copyTemplate() {
    
    local template=${1}
    local file=${2}

    log "INFO: Building silent install response file..."

    ${cp} ${template} ${file}
    checkStatus ${?} "ERROR: Unable to copy ${template} to ${file}. Exiting."

}

# Change directory to the product staging directory
function cdToStagingDir() {
    
    local directory=${1}
    cd ${directory}

}

# Give 755 access to the staging dir
function grantAccessToStagingDir() {
    
    ${chmod} 755 ${stagingDir}

} 

# Do initialization stuff
function init() {

    local component=${1}
    local operation=${2}

    redirectOutput
    checkForRoot
    grantAccessToStagingDir
    checkForLogDir    

    if [ ${operation} == "install" ]; then

        local installDir

        if [ ${component} == "db2" ]; then
            installDir=${db2InstallDir}
        elif [ ${component} == "iim" ]; then
            installDir=${iimInstallDir}
        elif [ ${component} == "was" ]; then
            installDir=${websphereInstallDir}
        elif [ ${component} == "tdi" ]; then
            installDir=${tdiInstallDir}
        else
            installDir=null 
        fi 

        # Only check for existing install if it's one we're interested in
        if [ ${installDir} != "null" ]; then
            local installed=$(isInstalled ${installDir})
            if [ ${installed} -eq 0 ]; then
                log "ERROR: Install directory ${installDir} already exists. Assuming ${component} is already installed. Exiting."    
                exit 1
            fi    
        fi

        clean ${component}
        cdToStagingDir ${component}

    fi

}

# Move live logs to archive directory
function logRotate() {

    local now=$(date '+%Y%m%d_%H%M%S')

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

}
