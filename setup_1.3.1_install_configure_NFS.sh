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
#
nfs_export_top="/NFS-export"
nfs_export_full="${nfs_export_top}/mp4library"
#
echo ""
set -x
sudo umount -f "${nfs_export_full}"
#
sudo systemctl stop nfs-kernel-server
sleep 3s
sudo apt purge -y nfs-kernel-server 
#sudo apt purge -y nfs-common
sudo apt autoremove -y
set +x
echo ""
set -x
sudo rm -fv "/etc/exports"
sudo rm -fv "/etc/default/nfs-kernel-server"
sudo rm -fv "/etc/idmapd.conf"
sudo rm -fvR "${nfs_export_full}"
sudo rm -fvR "${nfs_export_top}"
sudo rm -fv "/etc/fstab.pre-nfs.old"
sudo sed -i "s;${server_root_folder} ${nfs_export_full};#${server_root_folder} /NFS-export/mp4library;g" "/etc/fstab"
set +x
echo ""
set -x
sudo apt install -y nfs-kernel-server 
#sudo apt install -y nfs-common
#sudo apt install --reinstall -y nfs-kernel-server 
#sudo apt install --reinstall -y nfs-common
sleep 3s
sudo systemctl stop nfs-kernel-server
sleep 3s
set +x
echo ""
#
echo ""
echo "# This MUST be run after the SAMBA installation."
echo ""
echo "# Now we add a line to file /etc/fstab so that the NFS share is mounted the same every time"
echo ""
##read -p "TEST TEST TEST Press Enter if ${nfs_export_top} and ${nfs_export_full} have no quotes around them"
echo ""
set -x
cd ~/Desktop
sudo mkdir -p "${nfs_export_full}"
sudo chmod -c a=rwx -R "${nfs_export_top}"
sudo chmod -c a=rwx -R "${nfs_export_full}"
sudo mount --bind "${server_root_folder}" "${nfs_export_full}" 
set +x
echo ""
set -x
sudo df
sudo blkid
echo ""
set +x
##read -p "Press Enter if mounted OK, otherwise Control-C now and fix it manually !" 
#
echo ""

set -x
sudo cp -fv "/etc/fstab" "/etc/fstab.pre-nfs.old"
sudo sed -i   "s;${server_root_folder} ${nfs_export_full};#${server_root_folder} /NFS-export/mp4library;g" "/etc/fstab"
sudo sed -i "$ a ${server_root_folder} ${nfs_export_full} defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=1000,gid=1000,noatime,x-systemd.device-timeout=120,bind 0 0" "/etc/fstab"
set +x
echo ""
set -x
sudo cat "/etc/fstab"
diff -U 1 "/etc/fstab.pre-nfs.old" "/etc/fstab" 
set +x
echo ""
##read -p "Press Enter if /etc/fstab is OK, otherwise Control-C now and fix it manually !" 
echo ""
#
# To export our directories to a local network 10.0.0.0/24, we add the following two lines to /etc/exports:
#${nfs_export_top}  ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,fsid=0,root_squash,anonuid=1000,anongid=1000)
#${nfs_export_full} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,nohide,anonuid=1000,anongid=1000)
# note: id 1000 is user Pi and group Pi
echo ""
set -x
sudo sed -i "s;${nfs_export_top}  ${server_ip}/24;#${nfs_export_top}  ${server_ip}/24;g" "/etc/exports"
sudo sed -i "s;${nfs_export_full} ${server_ip}/24;#${nfs_export_full} ${server_ip}/24;g" "/etc/exports"
sudo sed -i "$ a ${nfs_export_top}  ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,fsid=0,root_squash,anonuid=1000,anongid=1000)" "/etc/exports"
sudo sed -i "$ a ${nfs_export_full} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,nohide,anonuid=1000,anongid=1000)" "/etc/exports"
cat /etc/exports
set +x
echo ""
#
#then check
# The only important option in # /etc/default/nfs-kernel-server for now is NEED_SVCGSSD. 
# It is set to "no" by default, which is fine, because we are not activating NFSv4 security this time.
echo ""
set -x
sudo sed -i 's;NEED_SVCGSSD="";NEED_SVCGSSD="no";g' "/etc/default/nfs-kernel-server"
set +x
echo "Check /etc/default/nfs-kernel-server has parameter:"
echo 'NEED_SVCGSSD="no"'
echo ""
set -x
cat "/etc/default/nfs-kernel-server"
set +x
echo ""
# In order for the ID names to be automatically mapped, the file /etc/idmapd.conf 
# must exist on both the client and the server with the same contents and with the correct domain names. 
# Furthermore, this file should have the following lines in the Mapping section:
#[Mapping]
#Nobody-User = nobody
#Nobody-Group = nogroup
echo ""
echo "Check /etc/idmapd.conf has "
echo "[Mapping]"
echo "Nobody-User = nobody"
echo "Nobody-Group = nogroup"
echo ""
set -x
cat "/etc/idmapd.conf"
set +x
echo ""
#
echo ""
set -x
sudo systemctl stop nfs-kernel-server
sleep 3s
sudo systemctl restart nfs-kernel-server
sleep 3s
set +x
echo ""
#
echo ""
##read -p "Press Enter to continue, if that all worked"
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
