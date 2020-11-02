#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# Build and configure HD-IDLE
# Call this .sh like:
# . "./setup_1.3_install_configure_SAMBA.sh"
#
set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# -------------"
echo "# INSTALL SAMBA"
echo "# -------------"
# https://magpi.raspberrypi.org/articles/raspberry-pi-samba-file-server
# https://pimylifeup.com/raspberry-pi-samba/

set -x
sudo systemctl stop smbd
sudo apt purge -y samba samba-common-bin
#sudo apt autoremove -y
sudo rm -vf "/etc/samba/smb.conf"
sudo rm -vf "/etc/samba/smb.conf.old"
#
sudo apt install -y samba samba-common-bin
#sudo apt install --reinstall -y samba samba-common-bin
set +x

echo ""
echo "Create a SAMBA password."
echo ""
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
set -x
sudo smbpasswd -a pi
sudo smbpasswd -a root
set +x
echo ""

echo ""
echo "Use a modified SAMBA conf with all of the good stuff"
url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/setup_support_files/smb.conf"
set -x
cd ~/Desktop
sudo rm -vf "./smb.conf"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "./smb.conf" --fail # -L means "allow redirection" or some odd :|
sudo cp -fv "./smb.conf"  "./smb.conf.old"
set +x
#---
echo "Start Adding stuff to './smb.conf' ..."
echo "[${server_alias}]">>"./smb.conf"
echo "comment=Pi4CC ${server_alias} home">>"./smb.conf"
echo "#force group = users">>"./smb.conf"
echo "#guest only = Yes">>"./smb.conf"
echo "guest ok = Yes">>"./smb.conf"
echo "public = yes">>"./smb.conf"
echo "#valid users = @users">>"./smb.conf"
echo "path = ${server_root_folder}">>"./smb.conf"
echo "available = yes">>"./smb.conf"
echo "read only = no">>"./smb.conf"
echo "browsable = yes">>"./smb.conf"
echo "writeable = yes">>"./smb.conf"
echo "#create mask = 0777">>"./smb.conf"
echo "#directory mask = 0777">>"./smb.conf"
echo "force create mode = 1777">>"./smb.conf"
echo "force directory mode = 1777">>"./smb.conf"
echo "inherit permissions = yes">>"./smb.conf"
echo "# 2020.08.10">>"./smb.conf"
echo "allow insecure wide links = yes">>"./smb.conf"
echo "follow symlinks = yes">>"./smb.conf"
echo "wide links = yes">>"./smb.conf"
echo "">>"./smb.conf"
if [ "${SecondaryDisk}" = "y" ]; then
	echo "[${server_alias}2]">>"./smb.conf"
	echo "comment=Pi4CC ${server_alias}2 home">>"./smb.conf"
	echo "#force group = users">>"./smb.conf"
	echo "#guest only = Yes">>"./smb.conf"
	echo "guest ok = Yes">>"./smb.conf"
	echo "public = yes">>"./smb.conf"
	echo "#valid users = @users">>"./smb.conf"
	echo "path = ${server_root_folder2}">>"./smb.conf"
	echo "available = yes">>"./smb.conf"
	echo "read only = no">>"./smb.conf"
	echo "browsable = yes">>"./smb.conf"
	echo "writeable = yes">>"./smb.conf"
	echo "#create mask = 0777">>"./smb.conf"
	echo "#directory mask = 0777">>"./smb.conf"
	echo "force create mode = 1777">>"./smb.conf"
	echo "force directory mode = 1777">>"./smb.conf"
	echo "inherit permissions = yes">>"./smb.conf"
	echo "# 2020.08.10">>"./smb.conf"
	echo "allow insecure wide links = yes">>"./smb.conf"
	echo "follow symlinks = yes">>"./smb.conf"
	echo "wide links = yes">>"./smb.conf"
	echo "">>"./smb.conf"
fi
echo "Finished Adding stuff to './smb.conf' ..."
#---
set -x
sudo chmod -c a=rwx -R *
sudo diff -U 10 "./smb.conf.old" "./smb.conf"
sudo rm -vf "/etc/samba/smb.conf.old"
sudo cp -fv "/etc/samba/smb.conf" "/etc/samba/smb.conf.old"
sudo cp -fv "./smb.conf" "/etc/samba/smb.conf"
diff -U 10 "/etc/samba/smb.conf.old" "/etc/samba/smb.conf"
sudo chmod -c a=rwx -R "/etc/samba"
set +x
# ignore this: # rlimit_max: increasing rlimit_max (1024) to minimum Windows limit (16384)

echo ""
echo "Test the samba config is OK"
echo ""
set -x
sudo testparm
set +x

echo ""
echo "Restart Samba service"
set -x
sudo systemctl stop smbd
sudo systemctl restart smbd
#sudo service smbd restart
sleep 10s
set +x

echo "List the new samba users (which can have different passwords to the Pi itself)"
set -x
sudo pdbedit -L -v
set +x

echo ""
echo "You can now access the defined shares from a Windows machine"
echo "or from an app that supports the SMB protocol"
echo "eg from Win10 PC in Windows Explorer use the IP address of ${server_name} like ... \\\\${server_ip}\\ "
set -x
hostname
hostname --fqdn
hostname --all-ip-addresses
set +x

echo ""
##read -p "Press Enter to continue, if that all worked"
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
