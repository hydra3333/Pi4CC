#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# Build and configure HD-IDLE
# Call this .sh like:
# . "./setup_0.2_setup_HD-IDLE.sh"
#
set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
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
echo "* THIS NEXT BIT IS VERY IMPORTANT - LOOK CLOSELY AND ACT IF NECESSARY                        "
echo "* THIS NEXT BIT IS VERY IMPORTANT - LOOK CLOSELY AND ACT IF NECESSARY                        "
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
sudo systemctl restart hd-idle
#sudo service hd-idle restart
sleep 5s
sudo cat /var/log/hd-idle.log
set +x

echo ""
echo "Finished INSTALL hd-idle so that external USB3 disks spin dowwn when idle and not wear out quickly."
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
