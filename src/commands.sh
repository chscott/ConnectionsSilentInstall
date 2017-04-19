stagingDir=$(pwd)
defaultPwd="password"
mkdir="/usr/bin/mkdir"
rm="/usr/bin/rm"
cd="/usr/bin/cd"
curl="/usr/bin/curl --silent --fail --remote-name"
tar="/usr/bin/tar"
unzip="/usr/bin/unzip"
grep="/usr/bin/grep"
sysgroupadd="/sbin/groupadd -r"
sysuseradd="/sbin/useradd -r -m"
groupdel="/sbin/groupdel"
userdel="/sbin/userdel"
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
su="/usr/bin/su"
awk="/usr/bin/awk"
sort="/usr/bin/sort"
tail="/usr/bin/tail"
cp="/usr/bin/cp"
sed="/usr/bin/sed"
xargs="/usr/bin/xargs"
ldconfig="/usr/sbin/ldconfig"
sh="/usr/bin/sh"
sudo="/usr/bin/sudo"
chown="/usr/bin/chown"
chmod="/usr/bin/chmod"
