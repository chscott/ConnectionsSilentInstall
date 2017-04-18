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
	
	log "Updating ${pamSshdFile}, ${pamSuFile}, and ${pamSudoFile} to include pam_limits.so..."

	# /etc/pam.d/sshd
	${grep} "pam_limits.so" ${pamSshdFile} >/dev/null 2>&1
	status=${?}
	if [ ${status} -ne 0 ]; then
		${printf} "${pamLimits}" >> ${pamSshdFile}
	else
		log "WARNING: ${pamSshdFile} already contains an entry for pam_limits.so. Manual review recommended."
	fi

	# /etc/pam.d/su
	${grep} "pam_limits.so" ${pamSuFile} >/dev/null 2>&1
	status=${?}
	if [ ${status} -ne 0 ]; then
		${printf} "${pamLimits}" >> ${pamSuFile}
	else
		log "WARNING: ${pamSuFile} already contains an entry for pam_limits.so. Manual review recommended."
	fi

	# /etc/pam.d/sudo
	${grep} "pam_limits.so" ${pamSudoFile} >/dev/null 2>&1
	status=${?}
	if [ ${status} -ne 0 ]; then
		${printf} "${pamLimits}" >> ${pamSudoFile}
	else
		log "WARNING: ${pamSudoFile} already contains an entry for pam_limits.so. Manual review recommended."
	fi
}
