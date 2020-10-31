#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# Build and configure miniDLNA
# Call this .sh like:
# . "./setup_1.2_install_configure_miniDLNA.sh"
#
set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# ----------------"
echo "# INSTALL minidlna"
echo "# ----------------"

# not strictly necessary to install, however it makes the server more "rounded" and accessible
# https://unixblogger.com/dlna-server-raspberry-pi-linux/
# https://www.youtube.com/watch?v=Vry0NpFjn5w
# https://www.deviceplus.com/how-tos/setting-up-raspberry-pi-as-a-home-media-server/

set -x
sudo apt purge minidlna -y
sudo apt autoremove -y
#sleep 3s
sudo rm -vfR "/etc/minidlna.conf"
sudo rm -vfR "/var/log/minidlna.log"
sudo rm -vfR "/run/minidlna"
sudo rm -vfR "${server_root_USBmountpoint}/minidlna"
set +x
echo ""


echo "Per https://wiki.debian.org/minidlna"
echo "To avoid Inotify errors, Increase the number for the system :"
echo "In /etc/sysctl.conf Add: "fs.inotify.max_user_watches=65536" in a blank line by itself."
echo ""


echo "# Do the minidlna install"
set -x
sudo apt install -y minidlna
sleep 3s
#
sudo systemctl stop minidlna
#sudo service minidlna stop
sleep 5s

echo "# Create a folder for minidlna logs and db - place the folder in the root of the (fast) USB3 drive"
set -x
sudo usermod -a -G www-data minidlna
sudo usermod -a -G pi minidlna
sudo usermod -a -G minidlna pi
sudo usermod -a -G minidlna root
#
sudo mkdir -p "${server_root_USBmountpoint}/minidlna"
sudo chmod -c a=rwx -R "${server_root_USBmountpoint}/minidlna"
sudo chown -c -R pi:minidlna "${server_root_USBmountpoint}/minidlna"
#
sudo chmod -c a=rwx -R   "/run/minidlna"
sudo chown -c -R pi:minidlna      "/run/minidlna"
#sudo chmod -c a=rwx -R   "/run/minidlna/minidlna.pid"
#sudo chown -c -R pi:minidlna      "/run/minidlna/minidlna.pid"
ls -al "/run/minidlna"
#
sudo chmod -c a=rwx -R "/etc/minidlna.conf"
sudo chown -c -R pi:minidlna "/etc/minidlna.conf"
#
sudo chmod -c a=rwx -R "/var/cache/minidlna"
sudo chown -c -R pi:minidlna "/var/cache/minidlna"
#
sudo chmod -c a=rwx -R "/var/log/minidlna.log"
sudo chown -c -R pi:minidlna "/var/log/minidlna.log"
cat "/var/log/minidlna.log"
#sudo rm -vfR "/var/log/minidlna.log"
#
set +x

echo ""
echo "# Change minidlna config settings to look like these"
echo ""
set -x
log_dir=${server_root_USBmountpoint}/minidlna
db_dir=${server_root_USBmountpoint}/minidlna
sh_dir=${server_root_USBmountpoint}/minidlna
sudo cp -fv "/etc/minidlna.conf" "/etc/minidlna.conf.old"
sudo sed -i "s;#user=minidlna;#user=minidlna\n#user=pi;g" "/etc/minidlna.conf"
sudo sed -i "s;media_dir=/var/lib/minidlna;#media_dir=/var/lib/minidlna\nmedia_dir=PV,${server_root_folder};g" "/etc/minidlna.conf"
sudo sed -i "s;#db_dir=/var/cache/minidlna;#db_dir=/var/cache/minidlna\ndb_dir=${db_dir};g" "/etc/minidlna.conf"
sudo sed -i "s;#log_dir=/var/log;#log_dir=/var/log\nlog_dir=${log_dir};g" "/etc/minidlna.conf"
sudo sed -i "s;#friendly_name=;#friendly_name=\nfriendly_name=${server_name}-minidlna;g" "/etc/minidlna.conf"
sudo sed -i "s;#inotify=yes;#inotify=yes\ninotify=yes;g" "/etc/minidlna.conf"
sudo sed -i "s;#strict_dlna=no;#strict_dlna=no\nstrict_dlna=yes;g" "/etc/minidlna.conf"
sudo sed -i "s;#notify_interval=895;#notify_interval=895\nnotify_interval=900;g" "/etc/minidlna.conf"
sudo sed -i "s;#max_connections=50;#max_connections=50\nmax_connections=6;g" "/etc/minidlna.conf"
sudo sed -i "s;#log_level=general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn;#log_level=general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn\nlog_level=artwork,database,general,http,inotify,metadata,scanner,ssdp,tivo=info;g" "/etc/minidlna.conf"
sudo sed -i "s;#wide_links=no;wide_links=yes;g" "/etc/minidlna.conf"
sudo diff -U 10 "/etc/minidlna.conf.old" "/etc/minidlna.conf"
set +x
echo ""

# after re-start, it looks for media
# force a re-scan at 4:00 am every night using crontab
# https://sourceforge.net/p/minidlna/discussion/879956/thread/41ae22d6/#4bf3
# To restart the service
#sudo service minidlna restart
set -x
sudo systemctl stop minidlna
#sudo service minidlna stop
sleep 3s
#
ls -al "/run/minidlna"
#
sudo systemctl start minidlna
#sudo service minidlna start
sleep 10s
#
ls -al "/run/minidlna"
cat ${log_dir}/minidlna.log
cat "/var/log/minidlna.log"
#
sudo systemctl reload-or-restart minidlna
#sudo service minidlna force-reload # same as systemctl reload-or-restart
sleep 10s
#
cat ${log_dir}/minidlna.log
cat "/var/log/minidlna.log"
set +x
#
Restart_sh_file=~/Desktop/minidlna_restart_refresh.sh
sh_file=${sh_dir}/minidlna_refresh.sh
log_file=${log_dir}/minidlna_refresh.log
main_log_dir=${log_dir}/minidlna.log
#
sudo rm -vf "${log_file}"
touch "${log_file}"
#
sudo rm -vf "${sh_file}"
echo "#!/bin/bash" >> "${sh_file}"
echo "set -x" >> "${sh_file}"
echo "sudo systemctl stop minidlna" >> "${sh_file}"
echo "#sudo service minidlna stop" >> "${sh_file}"
echo "sleep 10s" >> "${sh_file}"
echo "sudo systemctl start minidlna" >> "${sh_file}"
echo "#sudo service minidlna start" >> "${sh_file}"
echo "sleep 10s" >> "${sh_file}"
echo "sudo systemctl reload-or-restart minidlna" >> "${sh_file}"
echo "#sudo service minidlna force-reload # same as systemctl reload-or-restart" >> "${sh_file}"
echo "echo 'Wait 15 minutes for minidlna to index media files'" >> "${sh_file}"
echo "echo 'For progress do: cat ${main_log_dir}'" >> "${sh_file}"
echo "sleep 900s" >> "${sh_file}"
echo "set +x" >> "${sh_file}"
#
sudo rm -vf "${Restart_sh_file}"
sudo cp -vf "${sh_file}" "${Restart_sh_file}"
sudo chmod -c a=rwx ~/Desktop/*.sh
echo "#" >> "${Restart_sh_file}"
echo "#${sh_file}" >> "${Restart_sh_file}"
echo "#" >> "${Restart_sh_file}"
echo "cat ${log_file}" >> "${Restart_sh_file}"
echo "#" >> "${Restart_sh_file}"
echo "cat ${main_log_dir}" >> "${Restart_sh_file}"
echo "#" >> "${Restart_sh_file}"
#
# https://stackoverflow.com/questions/610839/how-can-i-programmatically-create-a-new-cron-job
echo ""
echo "Adding the 4:00am nightly crontab job to re-index minidlna"
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
( crontab -l ; echo "0 4 * * * ${sh_file} 2>&1 >> ${log_file}" ) 2>&1 | sed "s/no crontab for $(whoami)//g" | sort - | uniq - | crontab -
set -x
crontab -l # after
#
grep CRON /var/log/syslog
set +x

echo "#"
echo "# The minidlna service comes with a small webinterface. "
echo "# This webinterface is just for informational purposes. "
echo "# You will not be able to configure anything here. "
echo "# However, it gives you a nice and short information screen how many files have been found by minidlna. "
echo "# minidlna comes with it’s own webserver integrated. "
echo "# This means that no additional webserver is needed in order to use the webinterface."
echo "# To access the webinterface, open your browser of choice and enter "
echo ""
set -x
curl -i http://127.0.0.1:8200
set +x
echo ""

# The actual streaming process
# A short overview how a connection from a client to the configured and running minidlna server could work. 
# In this scenario we simply use a computer which is in the same local area network than the server. 
# As the client software we use the Video Lan Client (VLC). 
# Simple, robust, cross-platform and open source. 
# After starting VLC, go to the playlist mode by pressing CTRL+L in windows. 
# You will now see on the left side a category which is called Local Network. 
# Click on Universal Plug’n’Play which is under the Local Network category. 
# You will then see a list of available DLNA service within your local network. 
# In this list you should see your DLNA server. 
# Navigate through the different directories for music, videos and pictures and select a file to start the streaming process

echo ""
##read -p "Press Enter to continue, if that all worked"
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
