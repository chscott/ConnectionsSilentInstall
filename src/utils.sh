stagingDir=$(pwd)
defaultPwd="password"
logFile="install.log"
mkdir="/usr/bin/mkdir"
rm="/usr/bin/rm"
cd="/usr/bin/cd"
curl="/usr/bin/curl --silent --fail --remote-name"
tar="/usr/bin/tar"
unzip="/usr/bin/unzip"
grep="/usr/bin/grep"
sysgroupadd="/sbin/groupadd -r"
sysuseradd="/sbin/useradd -r -m"
chpasswd="/sbin/chpasswd"
echo="/usr/bin/echo"
printf="/usr/bin/printf"
limitsFile="/etc/security/limits.conf"
limitFilesSoft="\tsoft\tnofile\t16384\n"
limitFilesHard="\thard\tnofile\t65536\n"
pamSshdFile="/etc/pam.d/sshd"
pamSuFile="/etc/pam.d/su"
pamSudoFile="/etc/pam.d/sudo"
pamLimits="session\trequired\tpam_limits.so\n"

function testForRoot() {
	if [ "${EUID}" -ne 0 ]; then
		log "This script needs to run as root. Exiting."
		exit 1
	else
		log "Script is running as root. Continuing..."
	fi
}

function log() {
	printf "${1}\n" >&2
}

function checkStatus() {
	if [ $1 -ne 0 ]; then
		log "$2"
		log "Exit status: $1"
		exit 1
	fi
}

function checkUserGroupStatus() {
	if [ $1 -ne 0 ]; then
		if [ $1 -eq 9 ]; then
			log "$3 already exists. Continuing..."	
		else
			log "$2 $3"
			log "Exit status: $1"
			exit 1
		fi
	fi
}

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
