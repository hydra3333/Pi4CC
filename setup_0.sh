#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# This will install some of the requisitive thuff, but not edit the config files etc

set -x
cd ~/Desktop

set +x
echo "# ------------------------------------------------------------------------------------------------------------------------"
set -x
cd ~/Desktop
set +x
host_name=$(hostname --fqdn)
host_ip=$(hostname -I | cut -f1 -d' ')
setup_config_file=./setup.config
if [[ -f "$setup_config_file" ]]; then  # config file already exists
    echo "Using prior answers as defaults..."
    set -x
	cat "$setup_config_file"
	set +x
	source "$setup_config_file" # use "source" to retrieve the previous answers and use those as  the defaults in prompting
	#read -e -p "This server_name (will become name of website) [${server_name_default}]: " -i "${server_name_default}" input_string
    #server_name="${input_string:-$server_name_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    #server_name=${server_name_default}
    #server_ip=${server_ip_default}
    server_name=${host_name}
    server_ip=${host_ip}
    read -e -p "This server_alias (will become a Virtual Folder within the website) [${server_alias_default}]: " -i "${server_alias_default}" input_string
    server_alias="${input_string:-$server_alias_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    read -e -p "Designate the mount point for the USB3 external hard drive [${server_root_USBmountpoint_default}]: " -i "${server_root_USBmountpoint_default}" input_string
    server_root_USBmountpoint="${input_string:-$server_root_USBmountpoint_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    read -e -p "Designate the root folder on the USB3 external hard drive [${server_root_folder_default}]: " -i "${server_root_folder_default}" input_string
    server_root_folder="${input_string:-$server_root_folder_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
else  # config file does not exist, prompt normally with successive defaults based on answers aqs we go along
    echo "No prior answers found, creating new default answers ..."
    #server_name_default=Pi4CC
    server_name_default=${host_name}
    server_ip_default=${host_ip}
    server_alias_default=mp4library
    ##server_root_USBmountpoint_default=/mnt/${server_alias_default}
    ##server_root_folder_default=${server_root_USBmountpoint_default}/${server_alias_default}
    #read -e -p "This server_name (will become name of website) [${server_name_default}]: " -i "${server_name_default}" input_string
    #server_name="${input_string:-$server_name_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    #server_name=${server_name_default}
    #server_ip=${server_ip_default}
    server_name=${host_name}
    server_ip=${host_ip}
    read -e -p "This server_alias (will become a Virtual Folder within the website) [${server_alias_default}]: " -i "${server_alias_default}" input_string
    server_alias="${input_string:-$server_alias_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    server_root_USBmountpoint_default=/mnt/${server_alias}
    read -e -p "Designate the mount point for the USB3 external hard drive [${server_root_USBmountpoint_default}]: " -i "${server_root_USBmountpoint_default}" input_string
    server_root_USBmountpoint="${input_string:-$server_root_USBmountpoint_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    server_root_folder_default=${server_root_USBmountpoint}/${server_alias}
    read -e -p "Designate the root folder on the USB3 external hard drive [${server_root_folder_default}]: " -i "${server_root_folder_default}" input_string
    server_root_folder="${input_string:-$server_root_folder_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
fi
# ALWAYS choose a USB3 Disk device and find it's UUID
# (The use/positioning of parentheses and curly-brackets in setting array elements is critical)
disk_name=()
device_label=()
device_uuid=()
device_fstype=()
device_size=()
device_mountpoint=()
while IFS= read -r -d $'\0' device; do
   d=$device
   device=${d/\/dev\//}
   x_disk_name=($device)
   x_device_name=($d)
   x_device_label="$(lsblk -n -p -l -o label ${d})"
   #x_device_uuid="$(blkid -o value -s UUID ${d})"
   x_device_uuid="$(lsblk -n -p -l -o uuid ${d})"
   x_device_fstype="$(lsblk -n -p -l -o fstype ${d})"
   x_device_size="$(lsblk -n -p -l -o size ${d})"
   x_device_mountpoint="$(lsblk -n -p -l -o mountpoint ${d})"
   if [[ "${x_device_uuid}" != "" ]] ; then
      #echo  "device valid ${x_device_name}"
      disk_name+="${x_disk_name}"
      device_name+="${x_device_name}"
      device_label+="${x_device_label}"
      #device_uuid+="${x_devfice_uuid}"
      device_uuid+="${x_device_uuid}"
      device_fstype+="${x_device_fstype}"
      device_size+="${x_device_size}"
      device_mountpoint+="${x_device_mountpoint}"
   fi
done < <(find "/dev/" -regex '/dev/sd[a-z][0-9]\|/dev/vd[a-z][0-9]\|/dev/hd[a-z][0-9]' -print0)
device_string_tabbed=()
device_string=()
for i in `seq 0 $((${#disk_name[@]}-1))`; do
   device_string+=("DISK=${disk_name[$i]}, DEVICE==${device_name[$i]}, LABEL=${device_label}, UUID=${device_uuid[$i]}, FS_TYPE=${device_fstype[$i]}, SIZE=${device_size[$i]}, MOUNT_POINT=${device_mountpoint[$i]}")
   device_string_tabbed+=("${disk_name[$i]}\t${name[$i]}\t${size[$i]}\t${device_name[$i]}\t${device_label}\t${device_uuid[$i]}\t${device_fstype[$i]}\t${device_size[$i]}\t${device_mountpoint[$i]}")
done
#for i in `seq 0 $((${#disk_name[@]}-1))`; do
#   echo -e "${i} ${device_string_tabbed[$i]}"
#done
#for i in `seq 0 $((${#disk_name[@]}-1))`; do
#   echo -e "${i} ${device_string[$i]}"
#done
#---
#---
menu_from_array () {
 select item; do
   # Check the selected menu item number
   if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $# ]; then
      #echo "The selected operating system is $REPLY $item"
      if [[ "$item" = "$2" ]] ; then
         echo "$2 ..."
         exit
      fi
      let "selected_index=${REPLY} - 1"
      selected_item=${item}
      #echo "The selected operating system is ${selected_index} ${selected_item}"
      break;
   else
      echo "Invalid selection: Select any number from 1-$#"
   fi
 done
}
echo ""
echo "Choose which device is the USB3 hard drive/partition containing the .mp4 files ! "
echo ""
exit_string="It isn't displayed, Exit immediately"
menu_from_array "${device_string[@]}" "${exit_string}"
server_USB3_DISK_NAME="${disk_name[${selected_index}]}"
server_USB3_DEVICE_NAME="${device_name[${selected_index}]}"
server_USB3_DEVICE_UUID="${device_uuid[${selected_index}]}"
echo ""
#
echo "(re)Saving the new answers to the config file for re-use as future defaults..."
sudo rm -fv "$setup_config_file"
echo "#" >> "$setup_config_file"
echo "server_name_default=${server_name}">> "$setup_config_file"
echo "server_ip_default=${server_ip}">> "$setup_config_file"
echo "server_alias_default=${server_alias}">> "$setup_config_file"
echo "server_root_USBmountpoint_default=${server_root_USBmountpoint}">> "$setup_config_file"
echo "server_root_folder_default=${server_root_folder}">> "$setup_config_file"
echo "server_USB3_DISK_NAME=${server_USB3_DISK_NAME}">> "$setup_config_file"
echo "server_USB3_DEVICE_NAME=${server_USB3_DEVICE_NAME}">> "$setup_config_file"
echo "server_USB3_DEVICE_UUID=${server_USB3_DEVICE_UUID}">> "$setup_config_file"
echo "#">> "$setup_config_file"
set -x
sudo chmod -c a=rwx -R "$setup_config_file"
cat "$setup_config_file"
set +x
echo ""
echo "              server_name=${server_name}"
echo "                server_ip=${server_ip}"
echo "             server_alias=${server_alias}"
echo "server_root_USBmountpoint=${server_root_USBmountpoint}"
echo "       server_root_folder=${server_root_folder}"
echo "    server_USB3_DISK_NAME=${server_USB3_DISK_NAME}"
echo "  server_USB3_DEVICE_NAME=${server_USB3_DEVICE_NAME}"
echo "  server_USB3_DEVICE_UUID=${server_USB3_DEVICE_UUID}"
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"

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
sudo chmod -c a=rwx -R ${${server_root_USBmountpoint}}
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
sudo sed -i "$ a UUID=${server_USB3_DEVICE_UUID} ${server_root_USBmountpoint} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=1000,gid=1000,noatime,x-systemd.device-timeout=120 0 2" "/etc/fstab"
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
read -p "Press Enter if /etc/fstab is OK, othwewise Control-C now and fix it manually !" 

echo ""
echo ""
echo "Get ready for IPv4 only"
set -x
# set a new permanent limit with:
sudo sed -i 's;net.ipv6.conf.all.disable_ipv6;#net.ipv6.conf.all.disable_ipv6;g' "/etc/sysctl.conf"
echo net.ipv6.conf.all.disable_ipv6 = 1 | sudo tee -a "/etc/sysctl.conf"
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
sudo sysctl fs.inotify.max_user_watches=131072
sudo sysctl -p
# set a new permanent limit with:
sudo sed -i 's;fs.inotify.max_user_watches=;#fs.inotify.max_user_watches=;g' "/etc/sysctl.conf"
echo fs.inotify.max_user_watches=131072 | sudo tee -a "/etc/sysctl.conf"
sudo sysctl -p
set +x
echo ""

echo ""
echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "INSTALL hd-idle so that external USB3 disks spin dowwn when idle and not wear out quickly."
echo ""
echo ""
echo "My WD external USB3 disks won't spin down on idle and HDPARM and SDPARM don't work on them."
echo " ... hd-idle appears to work though, so let's use that."
echo ""
#
# https://www.htpcguides.com/spin-down-and-manage-hard-drive-power-on-raspberry-pi/
#
echo ""
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "* THIS NEXT BIT IS VERY IMPORTANT - LOOKL CLOSELY AND ACT IF NECESSARY                        "
echo "* THIS NEXT BIT IS VERY IMPORTANT - LOOKL CLOSELY AND ACT IF NECESSARY                        "
echo "*                                                                                             "
echo "*                                                                                             "
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "    server_USB3_DISK_NAME=${server_USB3_DISK_NAME}"
echo "  server_USB3_DEVICE_NAME=${server_USB3_DEVICE_NAME}"
echo "  server_USB3_DEVICE_UUID=${server_USB3_DEVICE_UUID}"
echo ""
set -x
blkid ${server_USB3_DEVICE_NAME}
df ${server_USB3_DEVICE_NAME}
lsblk ${server_USB3_DEVICE_NAME}
set +x
echo ""
echo ""
echo "Install hd-idle and point it at the external USB3 drive :-"
echo ""
echo "List and Remove any prior hd-idle package"
echo ""
set -x
sudo dpkg -l hd-idle
sudo apt purge -y hd-idle
set +x
echo ""
echo "Install hd-idle and dependencies"
echo ""
set -x
sudo apt-get install build-essential fakeroot debhelper -y
wget http://sourceforge.net/projects/hd-idle/files/hd-idle-1.05.tgz
tar -xvf hd-idle-1.05.tgz
cd hd-idle
dpkg-buildpackage -rfakeroot
sudo dpkg -i ../hd-idle_*.deb
cd ..
sudo dpkg -l hd-idle
set +x
echo ""
echo "Install hd-idle and dependencies"
echo ""
# option -d = debug
##Double check hd-idle works with your hard drive
##sudo hd-idle -t ${server_USB3_DEVICE_NAME} -d
#   #Command line options:
#   #-a name Set device name of disks for subsequent idle-time parameters -i. This parameter is optional in the sense that there's a default entry for all disks which are not named otherwise by using this parameter. This can also be a symlink (e.g. /dev/disk/by-uuid/...)
#   #-i idle_time Idle time in seconds for the currently named disk(s) (-a name) or for all disks.
#   #-c command_type Api call to stop the device. Possible values are scsi (default value) and ata.
#   #-s symlink_policy Set the policy to resolve symlinks for devices. If set to 0, symlinks are resolve only on start. If set to 1, symlinks are also resolved on runtime until success. By default symlinks are only resolve on start. If the symlink doesn't resolve to a device, the default configuration will be applied.
#   #-l logfile Name of logfile (written only after a disk has spun up or spun down). Please note that this option might cause the disk which holds the logfile to spin up just because another disk had some activity. On single-disk systems, this option should not cause any additional spinups. On systems with more than one disk, the disk where the log is written will be spun up. On raspberry based systems the log should be written to the SD card.
#   #-t disk Spin-down the specified disk immediately and exit.
#   #-d Debug mode. It will print debugging info to stdout/stderr (/var/log/syslog if started with systemctl)
#   #-h Print usage information.
## observe output
##Use Ctrl+C to stop hd-idle in the terminal
echo ""
echo "Modify the hd-idle configuration file to enable the service to automatically start and spin down drives"
echo ""
set -x
the_default_timeout=300
the_sda_timeout=900
set +x
echo ""
set -x
sudo cp -fv "/etc/default/hd-idle" "/etc/default/hd-idle.old"
sudo sed -i "s;START_HD_IDLE=;#START_HD_IDLE=;g" "/etc/default/hd-idle"
sudo sed -i "s;HD_IDLE_OPTS=;#HD_IDLE_OPTS=;g" "/etc/default/hd-idle"
sudo sed -i "2 i START_HD_IDLE=true" "/etc/default/hd-idle" # insert at line 2
sudo sed -i "$ a HD_IDLE_OPTS=\"-i ${the_default_timeout} -a ${server_USB3_DISK_NAME} -i ${the_sda_timeout} -l /var/log/hd-idle.log\"" "/etc/default/hd-idle" # insert as last line
sudo cat "/etc/default/hd-idle"
diff -U 1 "/etc/default/hd-idle.old" "/etc/default/hd-idle"
set +x
echo ""
echo "Restart the hd-idle service to engage the updated config"
echo ""
set -x
sudo service hd-idle restart
sleep 5s
sudo cat /var/log/hd-idle.log
set +x

echo ""
echo "Finished INSTALL hd-idle so that external USB3 disks spin dowwn when idle and not wear out quickly."
echo ""
echo "---------------------------------------------------------------------------------------------------"

echo ""
echo "# We should REBOOT the Pi now."
read -p "Press Enter to reboot then start the next setup script"

exit
