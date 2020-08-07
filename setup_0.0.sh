#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#

set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
# Ask for and setup default settings and try to remember them
. "./setup_0.1_ask_defaults.sh"
echo "# ------------------------------------------------------------------------------------------------------------------------"

set -x
# allow sources
sudo sed -i 's/# deb/deb/g' /etc/apt/sources.list
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
#echo "# Disable IPv6"
echo "# Remember to ALWAYS set the Pi to boot to GUI, EVEN IF later running it headless (see later)."
echo "#    Yes against most security recommendations, also check and set the Pi to auto-login."
echo ""
read -p "If not done that, please cancel this script now"
echo ""

set -x
ifconfig
set +x
echo "# If not already done, Reserve an IP in the home Router, corresponding to the Pi's mac address, then reboot the Pi."
read -p "If not already done, Reserve an IP in the home Router, corresponding to the Pi's mac address, then reboot the Pi."
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
##read -p "Press Enter to continue"
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
##read -p "Press Enter to continue, if you are happy so far"

echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"

set -x
sudo apt update -y
sudo apt full-upgrade -y # https://www.abc.net.au/radio/programs/coronacast/what-state-is-most-primed-for-a-coronavirus-outbreak/12475136
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
sudo chmod -c a=rwx -R ${server_root_USBmountpoint}
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
sudo blkid 
set +x
echo ""

echo ""
echo "# Note line showing the disk with the label we're interested in eg ${server_USB3_DEVICE_NAME} with UUID=${server_USB3_DEVICE_UUID}"
echo ""
#echo " for kicks, see what filesystems are supported"
#set -x
#ls -al "/lib/modules/$(uname -r)/kernel/fs/"
#set +x

echo ""
echo ""
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "* THIS NEXT BIT IS VERY IMPORTANT - LOOK CLOSELY AND ACT IF NECESSARY                         "
echo "* THIS NEXT BIT IS VERY IMPORTANT - LOOK CLOSELY AND ACT IF NECESSARY                         "
echo ""
echo "# Now we add a line to file /etc/fstab so that the external USB3 drive is installed the same every time"
echo "# (remember, always be consistent and plugin the USB3 drive into the bottom USB3 socket)"
echo "# https://wiki.debian.org/fstab"
echo ""
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
set -x
sudo cp -fv "/etc/fstab" "/etc/fstab.old"
sudo sed -i "s/UUID=${server_USB3_DEVICE_UUID}/#UUID=${server_USB3_DEVICE_UUID}/g" "/etc/fstab"
sudo sed -i "$ a #UUID=${server_USB3_DEVICE_UUID} ${server_root_USBmountpoint} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=1000,gid=1000,noatime,x-systemd.device-timeout=120 0 2" "/etc/fstab"
sudo sed -i "$ a UUID=${server_USB3_DEVICE_UUID} ${server_root_USBmountpoint} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=1000,gid=1000,noatime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
set +x
echo " You MUST check /etc/fstab NOW ... if it is incorrect then abort this process NOW and fix it manually"
echo " You MUST check /etc/fstab NOW ... if it is incorrect then abort this process NOW and fix it manually"
echo " You MUST check /etc/fstab NOW ... if it is incorrect then abort this process NOW and fix it manually"
echo ""
set +x
diff -U 1 "/etc/fstab.old" "/etc/fstab" 
sudo cat "/etc/fstab"
set +x
echo ""
##read -p "Press Enter if /etc/fstab is OK, otherwise Control-C now and fix it manually !" 

echo ""
echo ""
echo "Get ready for IPv4 only"
set -x
# set a new permanent limit with:
sudo sysctl net.ipv6.conf.all.disable_ipv6=1 
sudo sysctl -p
sudo sed -i 's;net.ipv6.conf.all.disable_ipv6;#net.ipv6.conf.all.disable_ipv6;g' "/etc/sysctl.conf"
echo net.ipv6.conf.all.disable_ipv6=1 | sudo tee -a "/etc/sysctl.conf"
sudo sysctl -p
set +x
echo ""

echo ""
echo "Get ready for minidlna. Increase system max_user_watches to avoid this error:"
echo "WARNING: Inotify max_user_watches [8192] is low or close to the number of used watches [2] and I do not have permission to increase this limit.  Please do so manually by writing a higher value into /proc/sys/fs/inotify/max_user_watches."
set -x
# sudo sed -i 's;8182;32768;g' "/proc/sys/fs/inotify/max_user_watches" # this fails with no permissions
sudo cat /proc/sys/fs/inotify/max_user_watches
# set a new temporary limit with:
#sudo sysctl fs.inotify.max_user_watches=131072
sudo sysctl fs.inotify.max_user_watches=262144
sudo sysctl -p
# set a new permanent limit with:
sudo sed -i 's;fs.inotify.max_user_watches=;#fs.inotify.max_user_watches=;g' "/etc/sysctl.conf"
#echo fs.inotify.max_user_watches=131072 | sudo tee -a "/etc/sysctl.conf"
echo fs.inotify.max_user_watches=262144 | sudo tee -a "/etc/sysctl.conf"
sudo sysctl -p
set +x
echo ""
echo ""
echo ""

exit

echo "# ------------------------------------------------------------------------------------------------------------------------"
## Build and configure HD-IDLE
cd ~/Desktop
. "./setup_0.2_setup_HD-IDLE.sh"
echo "# ------------------------------------------------------------------------------------------------------------------------"

echo ""
echo ""
echo "Remember, to disable WiFi:"
echo "add this line to '/boot/config.txt' and then reboot for it to take effect"
echo "dtoverlay=pi3-disable-wifi"
echo ""
echo ""
echo "Please Reboot now for the USB disk naming to take effect, before attempting to run setup_1.0.sh"
echo "Please Reboot now for the USB disk naming to take effect, before attempting to run setup_1.0.sh"
echo "Please Reboot now for the USB disk naming to take effect, before attempting to run setup_1.0.sh"
echo ""

exit
