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
		log "Script ${0} needs to run as root. Exiting."
		exit 1
	else
		log "Script ${0} is running as root. Continuing..."
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
		log "$2"
		log "Exit status: $1"
		exit 1
	fi
}

# Check exit code of database operation. Per the DB2 doc, the -s option
# means an error if the exit code is not 0, 1, or 2.
function checkStatusDb() {
	if [ ${1} -ne 0 -a ${1} -ne 1 -a ${1} -ne 2 ]; then
		log "$2"
		log "Exit status: $1"
		exit 1
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
                log "$3 already exists. Continuing..."	
            # Fatal
            else
                log "$2 $3"
                log "Exit status: $1"
                exit 1
            fi
        fi
    elif [ $4 == "DELETE" ]; then
        # Non-fatal error
        if [ $1 -ne 0 ]; then
            log "$2 $3"
            log "Exit status: $1"
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

    log "Downloading ${file} from ${ftpServer}..."
    
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

    log "Unpacking ${file}..."

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

    log "Unpacking ${file} to ${directory}..."

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

    log "Recreating product install staging directory..."

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

    log "Building silent install response file..."

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

    component=${1}
    operation=${2}

    redirectOutput
    checkForRoot
    grantAccessToStagingDir
    checkForLogDir    

    if [ ${operation} == "install" ]; then
        clean ${component}
        cdToStagingDir ${component}
    fi

}
