#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# This will install some of the requisitive thuff, but not edit the config files etc

set -x
cd ~/Desktop

set +x
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
set -x
cd ~/Desktop
set +x
setup_config_file=./setup.config
if [[ -f "$setup_config_file" ]]; then  # config file already exists
    echo "Using prior answers as defaults..."
    set -x
	cat "$setup_config_file"
	set +x
	source "$setup_config_file" # use "source" to retrieve the previous answers and use those as  the defaults in prompting
    read -e -p "This server_name (will become name of website) [${server_name_default}]: " -i "${server_name_default}" input_string
    server_name="${input_string:-$server_name_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    read -e -p "This server_alias (will become a Virtual Folder within the website) [${server_alias_default}]: " -i "${server_alias_default}" input_string
    server_alias="${input_string:-$server_alias_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    read -e -p "Designate the mount point for the USB3 external hard drive [${server_root_USBmountpoint_default}]: " -i "${server_root_USBmountpoint_default}" input_string
    server_root_USBmountpoint="${input_string:-$server_root_USBmountpoint_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    read -e -p "Designate the root folder on the USB3 external hard drive [${server_root_folder_default}]: " -i "${server_root_folder_default}" input_string
    server_root_folder="${input_string:-$server_root_folder_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
else  # config file does not exist, prompt normally with successive defaults based on answers aqs we go along
    echo "No prior answers found, creating new default answers ..."
    server_name_default=Pi4CC
    server_alias_default=mp4library
    ##server_root_USBmountpoint_default=/mnt/${server_alias_default}
    ##server_root_folder_default=${server_root_USBmountpoint_default}/${server_alias_default}
    read -e -p "This server_name (will become name of website) [${server_name_default}]: " -i "${server_name_default}" input_string
    server_name="${input_string:-$server_name_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    read -e -p "This server_alias (will become a Virtual Folder within the website) [${server_alias_default}]: " -i "${server_alias_default}" input_string
    server_alias="${input_string:-$server_alias_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    server_root_USBmountpoint_default=/mnt/${server_alias}
    read -e -p "Designate the mount point for the USB3 external hard drive [${server_root_USBmountpoint_default}]: " -i "${server_root_USBmountpoint_default}" input_string
    server_root_USBmountpoint="${input_string:-$server_root_USBmountpoint_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    server_root_folder_default=${server_root_USBmountpoint}/${server_alias}
    read -e -p "Designate the root folder on the USB3 external hard drive [${server_root_folder_default}]: " -i "${server_root_folder_default}" input_string
    server_root_folder="${input_string:-$server_root_folder_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
fi
echo "(re)saving the new answers to the config file for re-use as future defaults..."
sudo rm -fv "$setup_config_file"
echo "#" >> "$setup_config_file"
echo "server_name_default=${server_name}">> "$setup_config_file"
echo "server_alias_default=${server_alias}">> "$setup_config_file"
echo "server_root_USBmountpoint_default=${server_root_USBmountpoint}">> "$setup_config_file"
echo "server_root_folder_default=${server_root_folder}">> "$setup_config_file"
echo "#">> "$setup_config_file"
set -x
sudo chmod a=rwx -R "$setup_config_file"
cat "$setup_config_file"
set +x
echo ""
echo "              server_name=${server_name}"
echo "             server_alias=${server_alias}"
echo "server_root_USBmountpoint=${server_root_USBmountpoint}"
echo "       server_root_folder=${server_root_folder}"
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"

set -x
sudo apt update -y
sudo apt upgrade -y
set +x

echo "# LETS INSTALL THE Pi 4"
echo "# ---------------------"
echo ""
echo "# BEFORE RUNNING THIS SCRIPT :-"
echo ""
echo "# Change server name to ${server_name}"
echo "# Enable SSH"
echo "# Enable VNC"
echo "# Set the video RAM to 384Mb"
echo "# Disable IPv6"
echo "# Remember to ALWAYS set the Pi to boot to GUI, EVEN IF later running it headless (see later)."
echo "#    Yes against most security recommendations, also check and set the Pi to auto-login."
echo ""
read -p "If not done that, please cancel this script now"
echo ""

set -x
ifconfig
set +x
echo "# If not already done, Reserve an IP in the home Router, corresponding to the Pi's WiFi mac address, then reboot the Pi."
read -p "If not already done, Reserve an IP in the home Router, corresponding to the Pi's WiFi mac address, then reboot the Pi."
echo ""

echo ""
set -x
sudo dhclient -r
sudo dhclient
set +x

echo ""
set -x
ifconfig
hostname
hostname --fqdn
hostname --all-ip-addresses
set +x

set -x
ifconfig
set +x
echo ""
echo "Check the reserved IP Address and Host name.  If no good, cancel this script and fix it."
echo ""
read -p "Hope the Reserved IP worked, please check the IP and hostname.  Press Enter to continue"

echo ""
echo "# Add 15 seconds for the USB3 drive to spin up.  Add the line at the top."
echo "# per https://www.raspberrypi.org/documentation/configuration/config-txt/boot.md"
echo ""
echo "# Adding a line 'boot_delay=15' at the top of '/boot/config.txt'"
echo ""
#sudo sed -i "1 i boot_delay=15" "/boot/config.txt" # doesn't work if the file has no line 1
set -x
sudo cp -fv "/boot/config.txt" "/boot/config.txt.old"
rm -f ./tmp.tmp
sudo sed -i "/boot_delay/d" "/boot/config.txt"
echo "boot_delay=15" > ./tmp.tmp
sudo cat /boot/config.txt >> ./tmp.tmp
sudo cp -fv ./tmp.tmp /boot/config.txt
rm -f ./tmp.tmp
diff -U 1 "/boot/config.txt.old" "/boot/config.txt"
cat "/boot/config.txt"
set +x

echo ""
read -p "Press Enter to continue"
echo ""
echo "Now,"
echo "# Use sudo raspi-config to set these options"
echo "# In Advanced Options"
echo "#   A5 Resolution "
echo "#      Choose 1920x1080 (and NOT 'default') "
echo "#      which magically enables VNC server to run even when a screen is not connected to the HDMI port"
echo "#   AA Video Output Video output options for Pi 4 "
echo "#      Enable 4Kp60 HDMI"
echo "#      Enable 4Kp60 resolution on HDMI0 (disables analog)"
echo "# Then check/change other settings"
echo ""
echo "(use <tab> and<enter> to move around raspi-config and choose menu items)"
echo ""
read -p "Press Enter to start sudo raspi-config to do that.  (exiting raspi-config will return here)"
echo ""

set -x
sudo raspi-config
set +x
echo ""
read -p "Press Enter to continue, if you are happy so far"

echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"

set -x
sudo apt update -y
sudo apt upgrade -y
set +x

echo ""

echo "# install a remote-printing feature so we can print from the Pi via the Windows 10 PC (see below)"
set -x
sudo apt install -y cups
set +x

echo "# install https for distros although not strictly needed"
set -x
sudo apt install -y apt-transport-https
set +x

echo "# install the tool to turn EOL in text files from windows to unix"
set -x
sudo apt install -y dos2unix
set +x

echo "# install the tool to download setup support files"
set -x
sudo apt install -y curl
set +x

echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# MOUNT THE EXTERNALLY-POWERED USB3 HARD DRIVE"
echo ""

echo "# Create a mount point for the USB3 drive, which we'll use in a minute."
echo "# In this case I want to call it mp4library."
set -x
sudo mkdir -p ${server_root_USBmountpoint}
set +x

echo "# Set protections so we can so ANYTHING with it (we are inside our own home LAN)"
set -x
sudo chmod a=rwx -R ${${server_root_USBmountpoint}}
set +x

echo "# Fix user rights to allow user pi so that it has no trouble"
echo "# with mounting external drives."
set -x
sudo usermod -a -G plugdev pi
set +x

echo "# Plugin the external USB3 drive into the USB3 socket in the Pi4."
echo "# Always use the same USB socket on the Pi."
echo "# Always use an externally-powered  USB3 drive, so that we have "
echo "# sufficient power and sufficient data transfer bandwidth."
echo "# The USB3 drive will auto mount with NTFS, under Raspbian Buster."
echo "# Now we need to find  stuff about the disk, so in a Terminal do"
echo ""
read -p "Press Enter AFTER you have plugged in the USB3 drive and waited 15 seconds for it to spin up and be recognised automatically"
echo ""

set -x
sudo df
set +x
echo ""

set -x
sudo blkid 
set +x
echo ""

echo "# NOW note line showing the disk with the label we're interested in eg /dev/sda2 and the UUID"
echo ""
read -p "Press Enter AFTER you have noted these things"

echo "# see what filesystems are supported"
set -x
ls -al "/lib/modules/$(uname -r)/kernel/fs/"
set +x

echo "# Now use nano to edit the file /etc/fstab so that the external USB3 drive is installed the same every time"
echo "# (remember, always be consistent and plugin the USB3 drive into the bottom USB3 socket)"
echo "# https://wiki.debian.org/fstab"
echo ""
echo "# ADD this line at the end of the file like this"
echo "# using the correct newly-discovered UUID"
echo "# exclude the '#' to make it active"
echo "#UUID=F8ACDEBBACDE741A ${server_root_USBmountpoint} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=1000,gid=1000,noatime,x-systemd.device-timeout=120 0 2"
echo ""
set -x
sudo cp -fv "/etc/fstab" "/etc/fstab.old"
sudo sed -i "$ a #UUID=F8ACDEBBACDE741A ${server_root_USBmountpoint} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=1000,gid=1000,noatime,x-systemd.device-timeout=120 0 2" "/etc/fstab"
sudo cat "/etc/fstab"
set +x
echo ""

read -p "Press Enter to start nano to uncomment the line and CHANGE to the correct UUID"

set -x
sudo nano /etc/fstab
set +x

set -x
#cat "/etc/fstab"
diff -U 1 "/etc/fstab.old" "/etc/fstab" 
set +x

echo ""
read -p "Press Enter to continue after doing the change to fstab"

echo "# We should REBOOT the Pi now."
read -p "Press Enter to reboot then start the next setup script"

exit
