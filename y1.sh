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
echo ""
set -x
#sudo umount -f "${nfs_export_full}"
#
sudo systemctl stop nfs-kernel-server
sleep 2s
#sudo apt purge -y nfs-common
sudo apt purge -y nfs-kernel-server 
sudo apt autoremove -y
set +x
echo ""
set -x
#sudo rm -fv "/etc/exports"
#sudo rm -fv "/etc/default/nfs-kernel-server"
#sudo rm -fv "/etc/idmapd.conf"
#sudo rm -fvR "${nfs_export_full}"
#sudo rm -fvR "${nfs_export_top}"
sudo rm -fv "/etc/fstab.pre-nfs.old"
set +x
echo ""
set -x
sudo apt install -y nfs-kernel-server 
sleep 2s
sudo systemctl stop nfs-kernel-server
sleep 2s
set +x
echo ""
#
echo ""
echo "Check that uid=1000 and gid=1000 match the user pi "
echo ""
pi_uid="$(id -r -u pi)"
pi_gid="$(id -r -g pi)"
echo "uid=$(id -r -u pi) gid=$(id -r -g pi)" 
echo ""
set -x
cd ~/Desktop
# sudo mount -v --bind  "existing-folder-tree" "new-mount-point-folder"
id -u pi
id -g pi
ls -al "${server_root_folder}" 
set +x
echo ""
echo ""
##read -p "Press Enter if /etc/fstab is OK, otherwise Control-C now and fix it manually !" 
echo ""
#
# To export our directories to a local network 10.0.0.0/24, we add the following two lines to /etc/exports:
#${nfs_export_top}  ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,fsid=0,root_squash,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))
#${nfs_export_full} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,nohide,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))
# note: id 1000 is user pi and group pi
echo ""
set -x
sudo sed -i "s;${server_root_folder} ;#${server_root_folder} ;g" "/etc/exports"
sudo sed -i "$ a ${server_root_folder} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,nohide,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
sudo sed -i "$ a ${server_root_folder} 127.0.0.1(rw,insecure,sync,no_subtree_check,all_squash,nohide,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
cat /etc/exports
set +x
echo ""
read -p "Press Enter if /etc/exports looks OK, otherwise Control-C now and fix it manually !" 
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
sudo exportfs -rav
#
sudo systemctl stop nfs-kernel-server
sleep 2s
sudo systemctl restart nfs-kernel-server
sleep 2s
set +x
echo ""
#
set -x
ls -al "${server_root_folder}" 
#
sudo umount -f "/tmp-NFS-mountpoint"
sudo mkdir -p "/tmp-NFS-mountpoint"
sudo chmod -c a=rwx -R "/tmp-NFS-mountpoint"
sudo ls -alR "/tmp-NFS-mountpoint/"
sudo mount -v -t nfs ${server_ip}:/${server_root_folder} "/tmp-NFS-mountpoint"
sudo mount
sudo df -h
sudo ls -alR "/tmp-NFS-mountpoint/"
sudo ls ${server_root_folder}
#sudo umount -f "/tmp-NFS-mountpoint"
# don't remove it as it may accidentally wipe the mounted drive !!!
set +x
#
echo ""
##read -p "Press Enter to continue, if that all worked"
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
