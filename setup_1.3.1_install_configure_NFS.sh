#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# Build and configure HD-IDLE
# Call this .sh like:
# . "./setup_1.3.1_install_configure_NFS.sh"
#
set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# ------------------"
echo "# INSTALL NFS SERVER"
echo "# ------------------"
# https://magpi.raspberrypi.org/articles/raspberry-pi-samba-file-server
# https://pimylifeup.com/raspberry-pi-samba/

set -x
#sudo apt purge -y nfs-kernel-server nfs-common
#sudo apt autoremove -y
#
sudo apt install -y nfs-kernel-server nfs-common
sudo apt install --reinstall -y nfs-kernel-server nfs-common
set +x

echo ""
echo ""
echo "# This MUST be run after the SAMBA installation."
echo ""
echo "# Now we add a line to file /etc/fstab so that the NFS share is mounted the same every time"
echo ""
nfs_export_top="/NFS-export"
nfs_export_full="${nfs_export_top}/mp4library"
read -p "TEST TEST TEST Press Enter if ${nfs_export_top} and ${nfs_export_full} have no quores around them"
set -x
cd ~/Desktop
sudo mkdir -p "${nfs_export_full}"
sudo chmod -c a=rwx -R "${nfs_export_top}"
sudo chmod -c a=rwx -R "${nfs_export_full}"
sudo mount --bind "${nfs_export_full}" "${server_root_folder}"
set +x
read -p "Press Enter if mounted OK, otherwise Control-C now and fix it manually !" 
#
set -x
sudo cp -fv "/etc/fstab" "/etc/fstab.pre-nfs.old"
sudo sed -i "s;${server_root_folder} ${nfs_export_full};#${server_root_folder} /NFS-export/mp4library;g" "/etc/fstab"
sudo sed -i "$ a ${server_root_folder} ${nfs_export_full} defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=1000,gid=1000,noatime,x-systemd.device-timeout=120,bind 0 0" "/etc/fstab"
set +x
echo ""
set +x
diff -U 1 "/etc/fstab.pre-nfs.old" "/etc/fstab" 
sudo cat "/etc/fstab"
set +x
echo ""
read -p "Press Enter if /etc/fstab is OK, otherwise Control-C now and fix it manually !" 

echo ""
##read -p "Press Enter to continue, if that all worked"
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
