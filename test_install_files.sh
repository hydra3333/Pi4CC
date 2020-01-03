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
    server_name=${server_name_default}
    server_ip=${server_ip_default}
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
    server_name=${server_name_default}
    server_ip=${server_ip_default}
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
echo "server_ip_default=${server_ip}">> "$setup_config_file"
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
echo "                server_ip=${server_ip}"
echo "             server_alias=${server_alias}"
echo "server_root_USBmountpoint=${server_root_USBmountpoint}"
echo "       server_root_folder=${server_root_folder}"
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"

set -x
sudo apt update -y
sudo apt upgrade -y
set +x


echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALL the chromecast WEB pages and javascript and pyhton code etc for ${server_alias}"
echo ""

# get each file individually rather than the full package
set +x
cd ~/Desktop
#---
# Top level files
sudo chown -R pi:www-data "/var/www"
sudo chmod a=rwx -R "/var/www"
#
sudo mkdir -p "/var/www/${server_name}"
sudo chown -R pi:www-data "/var/www/${server_name}"
sudo chmod a=rwx -R "/var/www/${server_name}"
set -x
copy_to_top() {
  the_file=$1
  the_url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/${the_file}"
  echo "----------- Processing file '${the_file}' '${the_url}' ..."
  #set -x
  sudo rm -f "/var/www/${server_name}/${the_file}"
  sudo curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$the_url" --retry 50 -L --output "/var/www/${server_name}/${the_file}" --fail # -L means "allow redirection" or some odd :|
  sudo cp -fv "/var/www/${server_name}/${the_file}" "./${the_file}.old"
  # the order is important in these sed edits
  sudo sed -i "s;10.0.0.6;${server_name};g" "/var/www/${server_name}/${the_file}"
  sudo sed -i "s;Pi4CC;${server_name};g" "/var/www/${server_name}/${the_file}"
  sudo sed -i "s;/mnt/mp4library/mp4library;${server_root_folder};g" "/var/www/${server_name}/${the_file}"
  sudo sed -i "s;mp4library\";${server_alias}\";g" "/var/www/${server_name}/${the_file}"
  sudo chmod a=rwx "/var/www/${server_name}/${the_file}"
  sudo chown pi:www-data "/var/www/${server_name}/${the_file}"
  sudo diff -U 1 "./${the_file}.old" "/var/www/${server_name}/${the_file}" 
  sudo rm -fv "./${the_file}.old"
  #set +x
  echo "----------- Finished Processing file '${the_file}' ..."
  return 0
}
set -x
copy_to_top index.html
copy_to_top CastVideos.js
copy_to_top ads.js
copy_to_top create-json.py
cat "/var/www/${server_name}/create-json.py"
read -p "Press Enter to contiue"
copy_to_top reload_media.js.sh
#copy_to_top media.js
set +x

#---
# css files
sudo mkdir -p "/var/www/${server_name}/css"
sudo chown -R pi:www-data "/var/www/${server_name}/css"
sudo chmod a=rwx -R "/var/www/${server_name}/css"
copy_to_css() {
  the_file=$1
  the_url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/css/${the_file}"
  echo "----------- Processing file '${the_file}' '${the_url}' ..."
  #set -x
  sudo rm -f "/var/www/${server_name}/css/${the_file}"
  sudo curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$the_url" --retry 50 -L --output "/var/www/${server_name}/css/${the_file}" --fail # -L means "allow redirection" or some odd :|
  sudo chmod a=rwx "/var/www/${server_name}/css/${the_file}"
  sudo chown pi:www-data "/var/www/${server_name}/css/${the_file}"
  #set +x
  echo "----------- Finished Processing file '${the_file}' '${the_url}' ..."
  return 0
}
set -x
copy_to_css CastVideos.css
set +x
#---
# image files
sudo mkdir -p "/var/www/${server_name}/imagefiles"
sudo chown -R pi:www-data "/var/www/${server_name}/imagefiles"
sudo chmod a=rwx -R "/var/www/${server_name}/imagefiles"
copy_to_imagefiles() {
  the_file=$1
  the_url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/imagefiles/${the_file}"
  echo "----------- Processing file '${the_file}' ${the_url} ..."
  #set -x
  sudo rm -f "/var/www/${server_name}/imagefiles/${the_file}"
  sudo curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$the_url" --retry 50 -L --output "/var/www/${server_name}/imagefiles/${the_file}" --fail # -L means "allow redirection" or some odd :|
  sudo chmod a=rwx "/var/www/${server_name}/imagefiles/${the_file}"
  sudo chown pi:www-data "/var/www/${server_name}/imagefiles/${the_file}"
  #set +x
  echo "----------- Finished Processing file '${the_file}' '${the_url}' ..."
  return 0
}
set -x
copy_to_imagefiles free-boat_02.jpg
copy_to_imagefiles favicon.ico
copy_to_imagefiles favicon-16x16.png
copy_to_imagefiles favicon-32x32.png
copy_to_imagefiles favicon-64x64.png
copy_to_imagefiles header_bg-top.png
copy_to_imagefiles header_bg.png
copy_to_imagefiles footer_bg.png
copy_to_imagefiles logo.png
copy_to_imagefiles play.png
copy_to_imagefiles play-hover.png
copy_to_imagefiles play-press.png
copy_to_imagefiles pause.png
copy_to_imagefiles pause-hover.png
copy_to_imagefiles audio_off.png
copy_to_imagefiles audio_on.png
copy_to_imagefiles audio_bg.png
copy_to_imagefiles audio_bg_track.png
copy_to_imagefiles audio_indicator.png
copy_to_imagefiles audio_bg_level.png
copy_to_imagefiles fullscreen_expand.png
copy_to_imagefiles fullscreen_collapse.png
copy_to_imagefiles skip.png
copy_to_imagefiles skip_hover.png
copy_to_imagefiles skip_press.png
copy_to_imagefiles live_indicator_active.png
copy_to_imagefiles live_indicator_inactive.png
copy_to_imagefiles timeline_bg_progress.png
copy_to_imagefiles timeline_bg_buffer.png
set +x
#---
set -x
sudo chown -R pi:www-data "/var/www/${server_name}"
sudo chmod a=rwx -R "/var/www/${server_name}"
set +x

echo ""
echo "# Setup mediainfo and pymediainfo ready for the python script to use"
set -x
sudo apt install -y mediainfo
pip3 install pymediainfo
set +x
echo ""

echo "RE-CREATE the essential JSON file consumed by the ${server_name} website"

echo ""
set -x
python3 /var/www/${server_name}/create-json.py --source_folder "${server_root_folder}" --filename-extension mp4 --json_file /var/www/${server_name}/media.js 2>&1 | tee /var/www/${server_name}/create-json.log
sudo chown -R pi:www-data "/var/www/${server_name}/media.js"
sudo chmod a=rwx "/var/www/${server_name}/media.js"
sudo chown -R pi:www-data "/var/www/${server_name}/create-json.log"
sudo chmod a=rwx "/var/www/${server_name}/create-json.log"
set +x

echo "Restart the Apache2 Service"
set -x
#sleep 3s
#systemctl restart apache2
sudo service apache2 restart
sleep 10s
set +x

echo ""
echo "Add a nightly job to crontab to RE-CREATE the essential JSON file consumed by the ${server_name} website"
echo ""
#The layout for a cron entry is made up of six components: minute, hour, day of month, month of year, day of week, and the command to be executed.
# m h  dom mon dow   command
# * * * * *  command to execute
# ┬ ┬ ┬ ┬ ┬
# │ │ │ │ │
# │ │ │ │ │
# │ │ │ │ └───── day of week (0 - 7) (0 to 6 are Sunday to Saturday, or use names; 7 is Sunday, the same as 0)
# │ │ │ └────────── month (1 - 12)
# │ │ └─────────────── day of month (1 - 31)
# │ └──────────────────── hour (0 - 23)
# └───────────────────────── min (0 - 59)
# https://stackoverflow.com/questions/610839/how-can-i-programmatically-create-a-new-cron-job
# <minute> <hour> <day> <month> <dow> <tags and command>
set -x
crontab -l # before
set +x
(crontab -l ; echo "0 5 * * * python3 /var/www/${server_name}/create-json.py --source_folder ${server_root_folder} ---filename-extension mp4 --json_file /var/www/${server_name}/media.js 2>&1 > /var/www/${server_name}/create-json.log") 2>&1 | sed "s/no crontab for $(whoami)//g" | sort - | uniq - | crontab -
set -x
crontab -l # after
set +x


