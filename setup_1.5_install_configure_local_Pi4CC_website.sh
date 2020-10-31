#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# Build and configure HD-IDLE
# Call this .sh like:
# . "./setup_1.5_install_configure_local_Pi4CC_website.sh"
#
set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALL the chromecast WEB pages and javascript and python code etc for ${server_alias} ${server_ip}"
echo ""

# get each file individually rather than the full package

#---
# Top level files
sudo chown -c -R pi:www-data "/var/www"
sudo chmod -c a=rwx -R "/var/www"
#
sudo mkdir -p "/var/www/${server_name}"
sudo chown -c -R pi:www-data "/var/www/${server_name}"
sudo chmod -c a=rwx -R "/var/www/${server_name}"
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
  sudo sed -i "s;10.0.0.6;${server_ip};g" "/var/www/${server_name}/${the_file}"
  sudo sed -i "s;Pi4CC;${server_name};g" "/var/www/${server_name}/${the_file}"
  sudo sed -i "s;/mnt/mp4library/mp4library;${server_root_folder};g" "/var/www/${server_name}/${the_file}"
  sudo sed -i "s;mp4library\";${server_alias}\";g" "/var/www/${server_name}/${the_file}"
  sudo chmod -c a=rwx -R "/var/www/${server_name}/${the_file}"
  sudo chown -c pi:www-data "/var/www/${server_name}/${the_file}"
  sudo diff -U 10 "./${the_file}.old" "/var/www/${server_name}/${the_file}" 
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
copy_to_top reload_media.js.sh
#copy_to_top media.js
set +x
#
unlink "/home/pi/Desktop/reload_media.js.sh"
rm -vf "/home/pi/Desktop/reload_media.js.sh"
ln -sf "/var/www/${server_name}/reload_media.js.sh" "/home/pi/Desktop/reload_media.js.sh"
ls -l "/home/pi/Desktop/reload_media.js.sh"
#
#---
# css files
sudo mkdir -p "/var/www/${server_name}/css"
sudo chown -c -R pi:www-data "/var/www/${server_name}/css"
sudo chmod -c a=rwx -R "/var/www/${server_name}/css"
copy_to_css() {
  the_file=$1
  the_url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/css/${the_file}"
  echo "----------- Processing file '${the_file}' '${the_url}' ..."
  #set -x
  sudo rm -f "/var/www/${server_name}/css/${the_file}"
  sudo curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$the_url" --retry 50 -L --output "/var/www/${server_name}/css/${the_file}" --fail # -L means "allow redirection" or some odd :|
  sudo chmod -c a=rwx -R "/var/www/${server_name}/css/${the_file}"
  sudo chown -c pi:www-data "/var/www/${server_name}/css/${the_file}"
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
sudo chown -c -R pi:www-data "/var/www/${server_name}/imagefiles"
sudo chmod -c a=rwx -R "/var/www/${server_name}/imagefiles"
copy_to_imagefiles() {
  the_file=$1
  the_url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/imagefiles/${the_file}"
  echo "----------- Processing file '${the_file}' ${the_url} ..."
  #set -x
  sudo rm -f "/var/www/${server_name}/imagefiles/${the_file}"
  sudo curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$the_url" --retry 50 -L --output "/var/www/${server_name}/imagefiles/${the_file}" --fail # -L means "allow redirection" or some odd :|
  sudo chmod -c a=rwx -R "/var/www/${server_name}/imagefiles/${the_file}"
  sudo chown -c pi:www-data "/var/www/${server_name}/imagefiles/${the_file}"
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
sudo chown -c -R pi:www-data "/var/www/${server_name}"
sudo chmod -c a=rwx -R "/var/www/${server_name}"
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
sudo chown -c -R pi:www-data "/var/www/${server_name}/media.js"
sudo chmod -c a=rwx -R "/var/www/${server_name}/media.js"
sudo chown -c -R pi:www-data "/var/www/${server_name}/create-json.log"
sudo chmod -c a=rwx -R "/var/www/${server_name}/create-json.log"
set +x

echo "Restart the Apache2 Service"
set -x
#sleep 3s
sudo systemctl restart apache2
#sudo service apache2 restart
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
(crontab -l ; echo "0 5 * * * /var/www/${server_name}/reload_media.js.sh") 2>&1 | sed "s/no crontab for $(whoami)//g" | sort - | uniq - | crontab -
set -x
crontab -l # after
#
grep CRON /var/log/syslog
set +x

echo ""
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "Visit the web page from a different PC to see if it all works:"
echo "   https://${server_ip}/${server_name}/"
echo ""
echo "You may need to accept that the self-signed security certificate is 'insecure' "
echo "(cough, it is secure, it's solely inside your LAN)"
echo "... and tell the browser to allow it (proceed to 'unsafe' website anyway)"
echo ""
echo "In Chrome browser, see 'hamburger' -> More Tools -> Developer Tools "
echo "and watch the instrumentation log fly along. (Don't)."
echo ""
echo ""
echo ""
echo "NOTES:"
echo ""
echo "# How to use the website site https://${server_name}/${server_ip}"
echo "# ------------------------------------------------------------------"
echo "# Notes:"
echo "# 1. https: is 'required' by google to cast videos to chromecast devices"
echo "# 2. All of the javascript runs on the client-side (i.e in the user browser)"
echo "# 3. The web page uses native HTML5 '<details>' for drop-down lists"
echo "# 4. On a tablet or PC, open web page https://${server_name}/${server_ip} IN A CHROME BROWSER ONLY"
echo "# 5. Click on a folder to see it drop down and display its list of .mp4 files"
echo "# 6. Click on a .mp4 file to load it into the browser"
echo "# 7. Check its the one you want, pause it, cast it to a chromecast device"
echo "# 8. Control playback via the web page"
echo "#"

echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
