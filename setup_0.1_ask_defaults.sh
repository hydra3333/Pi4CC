#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# Determine the settings to apply, based in prior answers.
# Call this .sh like:
# . "./setup_0.1_ask_defaults.sh"
#
set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
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
	#
    read -e -p "Designate the mount point for the USB3 external hard drive [${server_root_USBmountpoint_default}]: " -i "${server_root_USBmountpoint_default}" input_string
    server_root_USBmountpoint="${input_string:-$server_root_USBmountpoint_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    read -e -p "Designate the root folder on the USB3 external hard drive [${server_root_folder_default}]: " -i "${server_root_folder_default}" input_string
    server_root_folder="${input_string:-$server_root_folder_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
	#
	SecondaryDisk=n
	server_root_USBmountpoint2=""
	server_root_folder2=""
	while true; do
		read -p "Do youhave a Secondary Media Disk [y/n]? " yn
		case $yn in
			[Yy]* ) SecondaryDisk=y; break;;
			[Nn]* ) SecondaryDisk=n; break;;
			* ) echo "Please answer y or n only.";;
		esac
	done
	if [ "${SecondaryDisk}" = "y" ]; then
		read -e -p "Designate the mount point for a SECOND USB3 external hard drive [${server_root_USBmountpoint2_default}]: " -i "${server_root_USBmountpoint_default}" input_string
		server_root_USBmountpoint2="${input_string:-$server_root_USBmountpoint2_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
		read -e -p "Designate the root folder on the SECOND USB3 external hard drive [${server_root_folder2_default}]: " -i "${server_root_folder2_default}" input_string
		server_root_folder2="${input_string:-$server_root_folder2_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
	fi
	#
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
	#
    server_root_USBmountpoint_default=/mnt/${server_alias}
    read -e -p "Designate the mount point for the USB3 external hard drive [${server_root_USBmountpoint_default}]: " -i "${server_root_USBmountpoint_default}" input_string
    server_root_USBmountpoint="${input_string:-$server_root_USBmountpoint_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
    server_root_folder_default=${server_root_USBmountpoint}/${server_alias}
    read -e -p "Designate the root folder on the USB3 external hard drive [${server_root_folder_default}]: " -i "${server_root_folder_default}" input_string
    server_root_folder="${input_string:-$server_root_folder_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
	#
	SecondaryDisk=n
	server_root_USBmountpoint2=""
	server_root_folder2=""
	while true; do
		read -p "Do you have a Secondary Media Disk [y/n]? " yn
		case $yn in
			[Yy]* ) SecondaryDisk=y; break;;
			[Nn]* ) SecondaryDisk=n; break;;
			* ) echo "Please answer y or n only.";;
		esac
	done
	if [ "${SecondaryDisk}" = "y" ]; then
		server_root_USBmountpoint2_default=/mnt/${server_alias}2
		read -e -p "Designate the mount point for a SECOND USB3 external hard drive [${server_root_USBmountpoint2_default}]: " -i "${server_root_USBmountpoint2_default}" input_string
		server_root_USBmountpoint2="${input_string:-$server_root_USBmountpoint2_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
		server_root_folder2_default=${server_root_USBmountpoint2}/${server_alias}
		read -e -p "Designate the root folder on the SECOND USB3 external hard drive [${server_root_folder2_default}]: " -i "${server_root_folder2_default}" input_string
		server_root_folder2="${input_string:-$server_root_folder2_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
	fi
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
   echo "***********************************"
   echo "EXAMIMING NEW DEVICE:"
   echo "d=${d}"
   echo "device=${device}"
   echo "x_disk_name=${x_disk_name}"
   echo "x_device_label=${x_device_label}"
   echo "x_device_uuid=${x_device_uuid}"
   echo "x_device_fstype=${x_device_fstype}"
   echo "x_device_size=${x_device_size}"
   echo "x_device_mountpoint=${x_device_mountpoint}"
   echo "***********************************"
   if [[ "${x_device_uuid}" != "" ]] ; then
      echo "FOUND device valid x_device_name=${x_device_name}"
      disk_name+=("${x_disk_name}")
      device_name+=("${x_device_name}")
      device_label+=("${x_device_label}")
      #device_uuid+=("${x_device_uuid}")
      device_uuid+=("${x_device_uuid}")
      device_fstype+=("${x_device_fstype}")
      device_size+=("${x_device_size}")
      device_mountpoint+=("${x_device_mountpoint}")
   fi
done < <(find "/dev/" -regex '/dev/sd[a-z][0-9]\|/dev/vd[a-z][0-9]\|/dev/hd[a-z][0-9]' -print0)
#---
#echo "????????????????????????"
#for t in ${disk_name[@]}; do
#  echo "1. ???? disk name=${t}"
#done
#echo "????????????????????????"
#for jj in ${!disk_name[@]}; do
#  echo "2. ???? jj=$jj disk name=${disk_name[$jj]}"
#done
#echo "????????????????????????"
#---
device_string_tabbed=()
device_string=()
for i in `seq 0 $((${#disk_name[@]}-1))`; do
   device_string+=("DISK=${disk_name[$i]}, DEVICE==${device_name[$i]}, LABEL=${device_label[$i]}, UUID=${device_uuid[$i]}, FS_TYPE=${device_fstype[$i]}, SIZE=${device_size[$i]}, MOUNT_POINT=${device_mountpoint[$i]}")
   device_string_tabbed+=("${disk_name[$i]}\t${name[$i]}\t${size[$i]}\t${device_name[$i]}\t${device_label}\t${device_uuid[$i]}\t${device_fstype[$i]}\t${device_size[$i]}\t${device_mountpoint[$i]}")
done
#---
#echo "????????????????????????"
#for i in `seq 0 $((${#disk_name[@]}-1))`; do
#   echo "i=${i} disk_name[${i}]=${disk_name[$i]}"
#done
#echo "????????????????????????"
#for i in `seq 0 $((${#disk_name[@]}-1))`; do
#   echo -e "TEST TABBED QUERY RESULTS: ${i} ${device_string_tabbed[$i]}"
#done
#echo "????????????????????????"
#for i in `seq 0 $((${#disk_name[@]}-1))`; do
#   echo -e "TEST NON-TABBED QUERY RESULTS: ${i} ${device_string[$i]}"
#done
#echo "????????????????????????"
#---
menu_from_array () {
 select item; do
   # Check the selected menu item number
   #echo "*** REPLY=${REPLY} *** item=${item}"
   if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $# ]; then
      if [ "$REPLY" -eq $# ]; then
		let "selected_index=0"
		selected_item=""
		echo "EXITING: selected_index:${selected_index} selected_item:${selected_item}..."
		break;
      fi
      let "selected_index=${REPLY} - 1"
      selected_item=${item}
      echo "The selected operating system is ${selected_index} ${selected_item}"
      break;
   else
      echo "Invalid number entered: Select any number from 1-$#"
   fi
 done
}
echo ""
echo "Choose which device is the MAIN USB3 hard drive/partition containing the .mp4 files ! "
echo ""
exit_string="It isn't displayed, Exit immediately"
menu_from_array "${device_string[@]}" "${exit_string}"
server_USB3_DISK_NAME="${disk_name[${selected_index}]}"
server_USB3_DEVICE_NAME="${device_name[${selected_index}]}"
server_USB3_DEVICE_UUID="${device_uuid[${selected_index}]}"
#
if [ "${SecondaryDisk}" = "y" ]; then
	echo ""
	echo "Choose which device is the 2nd USB3 hard drive/partition containing the .mp4 files ! "
	echo ""
	exit_string="It isn't displayed, Exit immediately"
	menu_from_array "${device_string[@]}" "${exit_string}"
	if [ "${selected_index}" -eq "0" ]; then
		SecondaryDisk=n
		server_USB3_DISK_NAME2=""
		server_USB3_DEVICE_NAME2=""
		server_USB3_DEVICE_UUID2=""
	else 
		server_USB3_DISK_NAME2="${disk_name[${selected_index}]}"
		server_USB3_DEVICE_NAME2="${device_name[${selected_index}]}"
		server_USB3_DEVICE_UUID2="${device_uuid[${selected_index}]}"
	fi
fi
echo ""
#
echo "(re)Saving the new answers to the config file for re-use as future defaults..."
sudo rm -fv "$setup_config_file"
echo "#" >> "$setup_config_file"
echo "server_name_default=${server_name}">> "$setup_config_file"
echo "server_ip_default=${server_ip}">> "$setup_config_file"
echo "server_alias_default=${server_alias}">> "$setup_config_file"
#
echo "server_root_USBmountpoint_default=${server_root_USBmountpoint}">> "$setup_config_file"
echo "server_root_folder_default=${server_root_folder}">> "$setup_config_file"
echo "server_USB3_DISK_NAME=${server_USB3_DISK_NAME}">> "$setup_config_file"
echo "server_USB3_DEVICE_NAME=${server_USB3_DEVICE_NAME}">> "$setup_config_file"
echo "server_USB3_DEVICE_UUID=${server_USB3_DEVICE_UUID}">> "$setup_config_file"
#
echo "SecondaryDisk=${SecondaryDisk}">> "$setup_config_file"
echo "server_root_USBmountpoint2_default=${server_root_USBmountpoint2}">> "$setup_config_file"
echo "server_root_folder2_default=${server_root_folder2}">> "$setup_config_file"
echo "server_USB3_DISK_NAME2=${server_USB3_DISK_NAME2}">> "$setup_config_file"
echo "server_USB3_DEVICE_NAME2=${server_USB3_DEVICE_NAME2}">> "$setup_config_file"
echo "server_USB3_DEVICE_UUID2=${server_USB3_DEVICE_UUID2}">> "$setup_config_file"
#
echo "#">> "$setup_config_file"
set -x
sudo chmod -c a=rwx -R "$setup_config_file"
cat "$setup_config_file"
set +x
echo "*****"
echo "               server_name=${server_name}"
echo "                 server_ip=${server_ip}"
echo "              server_alias=${server_alias}"
echo ""
echo " server_root_USBmountpoint=${server_root_USBmountpoint}"
echo "        server_root_folder=${server_root_folder}"
echo "     server_USB3_DISK_NAME=${server_USB3_DISK_NAME}"
echo "   server_USB3_DEVICE_NAME=${server_USB3_DEVICE_NAME}"
echo "   server_USB3_DEVICE_UUID=${server_USB3_DEVICE_UUID}"
echo ""
if [ "${SecondaryDisk}" = "y" ]; then
	echo "             SecondaryDisk=${SecondaryDisk}"
	echo "server_root_USBmountpoint2=${server_root_USBmountpoint2}"
	echo "       server_root_folder2=${server_root_folder2}"
	echo "    server_USB3_DISK_NAME2=${server_USB3_DISK_NAME2}"
	echo "  server_USB3_DEVICE_NAME2=${server_USB3_DEVICE_NAME2}"
	echo "  server_USB3_DEVICE_UUID2=${server_USB3_DEVICE_UUID2}"
fi
echo "*****"
echo "# ------------------------------------------------------------------------------------------------------------------------"
