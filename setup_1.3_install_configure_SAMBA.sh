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
#sudo apt purge -y samba samba-common-bin
#sudo apt autoremove -y
#sudo rm -fv -fv "/etc/samba/smb.conf"
#
sudo apt install -y samba samba-common-bin
sudo apt install --reinstall -y samba samba-common-bin
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
rm -f "./smb.conf"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "./smb.conf" --fail # -L means "allow redirection" or some odd :|
sudo cp -fv "./smb.conf"  "./smb.conf.old"
#---
##sudo sed -i "s;\[Pi\];\[Pi\];g"  "./smb.conf"
##sudo sed -i "s;\[Pi\];\[${server_name}\];g"  "./smb.conf"
sudo sed -i "s;comment=Pi4CC pi home;comment=${server_name} pi_home;g"  "./smb.conf"
##sudo sed -i "s;path = /home/pi;path = /home/pi;g"  "./smb.conf"
#---
sudo sed -i "s;\[mp4library\];\[${server_alias}\];g"  "./smb.conf"
sudo sed -i "s;comment=Pi4CC mp4library home;${server_name} ${server_alias} home;g"  "./smb.conf"
sudo sed -i "s;path = /mnt/mp4library;path = ${server_root_USBmountpoint};g"  "./smb.conf"
#---
##sudo sed -i "s;\[www\];\[www\];g"  "./smb.conf"
sudo sed -i "s;comment=Pi4CC www home;comment=${server_name} www home;g"  "./smb.conf"
##sudo sed -i "s;path = /var/www;path = /var/www;g"  "./smb.conf"
#---
sudo chmod -c a=rwx -R *
sudo diff -U 1 "./smb.conf.old" "./smb.conf"
sudo mv -fv "./smb.conf" "/etc/samba/smb.conf"
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
sudo systemctl stop restart
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
