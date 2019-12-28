#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# This will install some of the requisitive thuff, but not edit the config files etc

set -x
cd ~/Desktop
server_name=Pi4cc
server_root=/mnt/mp4library
server_root_folder=/mnt/mp4library/mp4library
set +x

sudo apt update -y
sudo apt upgrade -y

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
echo "# Yes against most security recommendations, also check and set the Pi to auto-login."
echo ""
read -p "If not done that, cancel this script now"
echo ""

set -x
ifconfig
set +x
echo "# Reserve an IP in the home Router, corresponding to the Pi's WiFi mac address, then reboot the Pi."
read -p "Reserve an IP in the home Router, corresponding to the Pi's WiFi mac address, then reboot the Pi."
echo ""

set -x
sudo dhclient -r
sudo dhclient
set +x

echo ""

set -x
ifconfig
set +x
read -p "Hope the Reserved IP worked. Press Enter to continue"
echo ""

set -x
ifconfig
hostname
hostname --fqdn
hostname --all-ip-addresses
set +x
read -p "Check the IP Address and Host name.  If no good, cancel this script and fix it."

echo ""
echo "# add 15 seconds for the USB3 drive to spin up.  Add the line at the top."
echo "# https://www.raspberrypi.org/documentation/configuration/config-txt/boot.md"
read -p "Press Enter to add a line 'boot_delay=15' at the top of '/boot/config.txt'"
echo ""
set -x
#sudo sed -i "1 i boot_delay=15" "/boot/config.txt" # doesn't work if the file has no line 1
sudo cp -fv "/boot/config.txt" "/boot/config.txt.old"
rm -f ./tmp.tmp
echo "boot_delay=15" > ./tmp.tmp
sudo cat /boot/config.txt >> ./tmp.tmp
sudo cp -fv ./tmp.tmp /boot/config.txt
rm -f ./tmp.tmp
diff -U 1 "/boot/config.txt.old" "/boot/config.txt"

set +x

echo ""
read -p "Press Enter to continue"

echo "# Use sudo raspi-config to set these options"
echo "# In Advanced Options"
echo "# Video Output Video output options for Pi 4 "
echo "# Enable 4Kp60 HDMI"
echo "# Enable 4Kp60 resolution on HDMI0 (disables analog)"
echo "# Then check/change other settings"
read -p "Press Enter to start sudo raspi-config to do that"

set -x
sudo raspi-config
set +x
read -p "Press Enter to continue"

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
sudo mkdir -p ${server_root}
set +x

echo "# Set protections so we can so ANYTHING with it (we are inside our own home LAN)"
set -x
sudo chmod +777 ${${server_root}}
set +x

echo "# Fix permissions to allow user pi so that it has no trouble"
echo "# with mounting external drives."
set -x
sudo usermod -a -G plugdev pi
set +x

echo "# Plugin a 5Tb external USB3 drive into the bottom USB3 socket in the Pi4."
echo "# Always use the same USB socket on the Pi."
echo "# Always use an externally-powered  USB3 drive, so that we have "
echo "# sufficient power and sufficient data transfer bandwidth."
echo "# The USB3 drive will auto mount with NTFS, under Raspbian Buster."
echo "# Now we need to find  stuff about the disk, so in a Terminal do"
echo ""
read -p "Press Enter AFTER you have plugged in the USB3 drive and waited 15 seconds"
echo ""

set -x
df
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
echo "#UUID=F8ACDEBBACDE741A ${server_root} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=1000,gid=1000,noatime,x-systemd.device-timeout=120 0 2"
echo ""
set -x
sudo cp -fv "/etc/fstab" "/etc/fstab.old"
sudo sed -i "$ a #UUID=F8ACDEBBACDE741A ${server_root} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=1000,gid=1000,noatime,x-systemd.device-timeout=120 0 2" "/etc/fstab"
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
