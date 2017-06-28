mkdir="/usr/bin/mkdir"
rm="/usr/bin/rm"
# cd doesn't work right when used this way
#cd="/usr/bin/cd"
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
head="/usr/bin/head"
cp="/usr/bin/cp"
sed="/usr/bin/sed"
xargs="/usr/bin/xargs"
ldconfig="/usr/sbin/ldconfig"
sh="/usr/bin/sh"
sudo="/usr/bin/sudo"
chown="/usr/bin/chown"
chmod="/usr/bin/chmod"
kill="/usr/bin/kill"
cat="/usr/bin/cat"
tr="/usr/bin/tr"
cut="/usr/bin/cut"
mv="/usr/bin/mv"
hostname="/usr/bin/hostname"
find="/usr/bin/find"
xargs="/usr/bin/xargs"
date="/usr/bin/date"
pwd="/usr/bin/pwd"
ps="/usr/bin/ps"
ls="/usr/bin/ls"
touch="/usr/bin/touch"
clear="/usr/bin/clear"
read="/usr/bin/read"
