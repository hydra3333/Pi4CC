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

echo "# Set permissions so we can do ANYTHING with the USB3 drive."
set -x
sudo chmod -c a=rwx -R ${server_root_USBmountpoint}
set +x

echo "# Check the exterrnal USB3 drive mounted where we told it to by doing a df"
set -x
df
set +x
##read -p "Press Enter to continue"

echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALLING APACHE & PHP"
echo ""
echo "#https://pimylifeup.com/raspberry-pi-apache/"
echo ""

set -x
# REMOVE PHP BEFORE INSTALL
sudo apt purge -y php7.3 
sudo apt purge -y php7.3-common 
sudo apt purge -y php7.3-cli 
sudo apt purge -y php7.3-intl 
sudo apt purge -y php7.3-curl 
sudo apt purge -y php7.3-xsl 
sudo apt purge -y php7.3-gd 
sudo apt purge -y php7.3-recode 
sudo apt purge -y php7.3-tidy 
sudo apt purge -y php7.3-json 
sudo apt purge -y php7.3-mbstring 
sudo apt purge -y php7.3-dev 
sudo apt purge -y php7.3-bz2 
sudo apt purge -y php7.3-zip 
sudo apt purge -y php-pear 
sudo apt purge -y libmcrypt-dev
sudo apt purge -y libapache2-mod-php
sudo apt autoremove -y
#sleep 3s
# REMOVE APACHE2 BEFORE INSTALL
sudo apt purge -y apache2 
sudo apt purge -y apache2-bin
sudo apt purge -y apache2-data
sudo apt purge -y apache2-utils
sudo apt purge -y apache2-doc
sudo apt purge -y apache2-suexec-pristine
sudo apt purge -y apache2-ssl-dev
#sudo apt purge -y libxml2 
#sudo apt purge -y libxml2-dev 
#sudo apt purge -y libxml2-utils
#sudo apt purge -y libaprutil1 
#sudo apt purge -y libaprutil1-dev
sudo apt purge -y libapache2-mod-gnutls 
sudo apt purge -y libapache2-mod-security2
sudo apt autoremove -y
#sleep 3s
# REMOVE CONFIG FILES
sudo rm -fv "/etc/php/7.3/apache2/php.ini"
##read -p "Press Enter to continue #"
sudo rm -fv "/etc/apache2/apache2.conf"
##read -p "Press Enter to continue #"
sudo rm -fv "/etc/apache2/mods-available/status.conf"
##read -p "Press Enter to continue #"
sudo rm -fv "/etc/apache2/mods-available/info.conf"
##read -p "Press Enter to continue #"
sudo rm -fv "/etc/apache2/sites-available/000-default.conf"
##read -p "Press Enter to continue #"
sudo rm -fv "/etc/apache2/sites-available/default-tls.conf"
##read -p "Press Enter to continue #"
# INSTALL APACHE2
sudo apt install -y apache2 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y apache2-bin
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y apache2-data
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y apache2-utils
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y apache2-doc
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y apache2-suexec-pristine
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y apache2-ssl-dev
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y libxml2 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y libxml2-dev 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y libxml2-utils
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y libaprutil1 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y libaprutil1-dev
#sleep 3s
##read -p "Press Enter to continue #"
# socache_dbm required for gnutls
sudo a2enmod socache_dbm
#sleep 3s
sudo apt install -y libapache2-mod-gnutls 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y libapache2-mod-security2
#sleep 3s
##read -p "Press Enter to continue #"
# Note: the version lile 7.3 will change as time passes !!!!!!!
# INSTALL PHP
sudo apt install -y php7.3 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-common 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-cli 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-intl 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-curl 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-xsl 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-gd 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-recode 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-tidy 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-json 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-mbstring 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-dev 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-bz2 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php7.3-zip 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y php-pear 
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y libmcrypt-dev
#sleep 3s
##read -p "Press Enter to continue #"
sudo apt install -y libapache2-mod-php
#sleep 3s
##read -p "Press Enter to continue #"
set +x

echo ""
##read -p "Press Enter to continue, if it installed correctly"

echo "Make changes to /etc/php/7.3/apache2/php.ini"
set -x
sudo cp -fv "/etc/php/7.3/apache2/php.ini" "/etc/php/7.3/apache2/php.ini.old"
sudo sed -i "s;max_execution_time = 30;max_execution_time = 300;g"          "/etc/php/7.3/apache2/php.ini"
sudo sed -i "s;max_input_time = 60;max_input_time = 300;g"                  "/etc/php/7.3/apache2/php.ini"
sudo sed -i "s;display_errors = Off;display_errors = On;g"                  "/etc/php/7.3/apache2/php.ini"
sudo sed -i "s;display_startup_errors = Off;display_startup_errors = On;g"  "/etc/php/7.3/apache2/php.ini"
sudo sed -i "s;log_errors_max_len = 1024;log_errors_max_len = 8192;g"       "/etc/php/7.3/apache2/php.ini"
sudo sed -i "s;default_socket_timeout = 60;default_socket_timeout = 300;g"  "/etc/php/7.3/apache2/php.ini"
sudo diff -U 1 "/etc/php/7.3/apache2/php.ini.old" "/etc/php/7.3/apache2/php.ini"
php -version
set +x

echo ""
##read -p "Press Enter to continue, if it there were 6 changes correctly"

echo "# Install python3"
set -x
#sudo apt purge -y python3 idle
sudo apt purge -y libapache2-mod-python
sudo apt autoremove -y
#sleep 5s
#
sudo apt install -y python3 
sudo apt install -y idle
#sleep 3s
sudo apt install -y libapache2-mod-python
#sleep 3s
set +x
##read -p "Press Enter to continue, if it worked correctly"

echo ""
echo "# OK, finished Apache2/Python3/PSH APT installs"

echo ""
echo "# Setup some handy protections"
set -x
sudo groupadd -f www-data
sudo usermod -a -G www-data root
sudo usermod -a -G www-data pi
sudo chown -c -R pi:www-data /var/www
sudo chmod -c a=rwx -R /var/www
#sleep 3s
cat /var/log/apache2/error.log
ls -al /etc/apache2/sites-enabled
ls -al /etc/apache2/sites-available
set +x
##read -p "Press Enter to continue, if it worked correctly"

echo ""
echo "# Enable/Disable Apache2 features"
set -x
sudo a2enmod headers
sudo a2enmod status
sudo a2enmod info
sudo a2enmod autoindex
sudo a2enmod negotiation
sudo a2enmod speling
sudo a2enmod socache_dbm
sudo a2enmod socache_shmcb
sudo a2dismod ssl
sudo a2enmod gnutls
sudo a2enmod php7.3
sudo a2enmod python
sudo a2enmod xml2enc
sudo a2enmod alias 
sudo a2enmod cgi
#sleep 3s
set +x
##read -p "Press Enter to continue, if it worked correctly"

#echo "# check the mp4 mime type is in place"
#ls -al /etc/mime.types
#sudo nano /etc/mime.types
## and check to see that these lines exist
#video/mp4   mp4
#video/wemb  webm
## hint, use control W which is nano's "find text"
## if they don't exist, add them
##control X

echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "Change some Apache2 settings"
echo ""
echo "## Just underneath the line"
echo '#ServerRoot "/etc/apache2"'
echo "## add this line to say the web server name is going to be ${server_name}"
echo "ServerName ${server_name}"
set -x
sudo cp -fv "/etc/apache2/apache2.conf" "/etc/apache2/apache2.conf.old"
sudo sed -i "s;#ServerRoot;#ServerRoot\nServerName ${server_name};g" "/etc/php/7.3/apache2/php.ini"
sudo sed -i "s;Timeout 300;Timeout 10800;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;MaxKeepAliveRequests 100;MaxKeepAliveRequests 0;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;KeepAliveTimeout 5;KeepAliveTimeout 10800;g" "/etc/apache2/apache2.conf"
# in reverse order
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nCheckCaseOnly On;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nCheckSpelling On;g" "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nHeader set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept";g' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nHeader set Access-Control-Allow-Origin "*";g' "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nHeader set Accept-Ranges bytes;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nMaxRangeReversals unlimited;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nMaxRangeOverlaps unlimited;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nMaxRanges unlimited;g" "/etc/apache2/apache2.conf"
# in reverse order
sudo sed -i "s;Include ports.conf;Include ports.conf\nCheckCaseOnly On;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;Include ports.conf;Include ports.conf\nCheckSpelling On;g" "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nHeader set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept";g' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nHeader set Access-Control-Allow-Origin "*";g' "/etc/apache2/apache2.conf"
sudo sed -i "s;Include ports.conf;Include ports.conf\nHeader set Accept-Ranges bytes;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;Include ports.conf;Include ports.conf\nMaxRangeReversals unlimited;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;Include ports.conf;Include ports.conf\nMaxRangeOverlaps unlimited;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;Include ports.conf;Include ports.conf\nMaxRanges unlimited;g" "/etc/apache2/apache2.conf"
# these don't occur in this file, however try anyway
sudo sed -i "s;Pi4CC;${server_name};g"  "/etc/apache2/apache2.conf"
sudo sed -i "s;/mnt/mp4library/mp4library;${server_root_folder};g"  "/etc/apache2/apache2.conf"
sudo sed -i "s;/mnt/mp4library;${server_root_USBmountpoint};g"  "/etc/apache2/apache2.conf"
sudo sed -i "s;mp4library;${server_alias};g"  "/etc/apache2/apache2.conf"
#
sudo diff -U 1 "/etc/apache2/apache2.conf.old" "/etc/apache2/apache2.conf"
set +x

echo ""
##read -p "Press Enter to continue, if the all of the apache2.conf worked correctly"
echo ""

echo '# Under the "Location /server-status" directive, '
echo '# Locate the "#Require ip 192.0.2.0/24" '
echo "# line and add a lind underneath for yout lan segment change"
echo "# of a the tablet or equipment on the LAN "
echo "# which you will be using to access the web server,"
echo ""
set -x
sudo cp -fv "/etc/apache2/mods-available/status.conf" "/etc/apache2/mods-available/status.conf.old"
sudo sed -i "s;#Require ip 192.0.2.0/24;#Require ip 192.0.2.0/24\n#Require ip 127.0.0.1\n#Require ip ${server_ip}/24;g" "/etc/apache2/mods-available/status.conf"
sudo diff -U 1 "/etc/apache2/mods-available/status.conf.old" "/etc/apache2/mods-available/status.conf"
set +x
echo ""
##read -p "Press Enter to continue, if the status.conf worked correctly"
echo ""

set -x
sudo cp -fv "/etc/apache2/mods-available/info.conf" "/etc/apache2/mods-available/info.conf.old"
sudo sed -i "s;#Require ip 192.0.2.0/24;#Require ip 192.0.2.0/24\n#Require ip 127.0.0.1\n#Require ip ${server_ip}/24;g" "/etc/apache2/mods-available/info.conf"
sudo diff -U 1 "/etc/apache2/mods-available/info.conf.old" "/etc/apache2/mods-available/info.conf"
set +x
echo ""
##read -p "Press Enter to continue, if the info.conf worked correctly"
echo ""

# Leave port 80 listening, so do not comment-out the line which says Listen 80 in /etc/apache2/ports.conf

echo "# Enable the apache default-tls site and enable the 000-default site (may disable 000-default one day)"
set -x
#ls -al /etc/apache2/sites-available
ls -al /etc/apache2/sites-enabled
sudo a2ensite default-tls
sudo a2ensite 000-default
ls -al /etc/apache2/sites-enabled
set +x
echo ""
##read -p "Press Enter to continue, if setting up Apache2 and Sites/Config worked correctly"
echo ""

echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Attempt to generate and install a self-signed SSL/TLS certificate"
echo "# -----------------------------------------------------------------"
echo ""
echo "# :(   Do this since Chromecasts complain if the serving web page isn't done via https:"
echo ""
echo "# FIND fqdn FOR USE IN CREATING THE SELF SIGNED CERTIFICATE FOR APACHE"
echo ""
set -x
hostname
hostname --fqdn
hostname --all-ip-addresses
set +x

# ++++++++++ BELOW worked however is likely not ideal ++++++++++
# ++++++++++ BELOW worked however is likely not ideal ++++++++++
# ++++++++++ BELOW worked however is likely not ideal ++++++++++
#
# https://the-bionic-cyclist.co.uk/2017/03/22/setup-ssl-on-a-raspberry-pi-in-2-minutes/
# https://stackoverflow.com/questions/21141215/creating-a-p12-file
# https://www.ssl.com/how-to/create-a-pfx-p12-certificate-file-using-openssl/
# https://stackoverflow.com/questions/21141215/creating-a-p12-file
# https://samhobbs.co.uk/2014/04/ssl-certificate-signing-cacert-raspberry-pi-ubuntu-debian

cd ~/Desktop

set +x

echo ""
echo "# Create the self-signed Certificate Files for use with TLS"
set -x
sudo mkdir -p /etc/tls/localcerts
set +x

echo ""
echo "# find local hostname eg ${server_name}"
set -x
hostname
hostname --fqdn
hostname --all-ip-addresses
set +x

echo ""
echo "# ASSUME THE HOSTNAME IS ${server_name} "
echo "#    IF NOT, exit this script and change it !!!!!"
echo "# Now Create the Certificate and Key (12650 = 50 years)"
echo "# REMEMBER any passwords !!!     Write them down !!!!"
echo ""
echo "Use Host (server) name ... the FQDN = ${server_name}"
echo "Use Host (server) name ... the FQDN = ${server_name}"
echo "Use Host (server) name ... the FQDN = ${server_name}"
echo "Use Host (server) name ... the FQDN = ${server_name}"
echo "Use Host (server) name ... the FQDN = ${server_name}"
echo "Use Host (server) name ... the FQDN = ${server_name}"
echo "Use Host (server) name ... the FQDN = ${server_name}"
echo "Use Host (server) name ... the FQDN = ${server_name}"
echo "Use Host (server) name ... the FQDN = ${server_name}"
echo "Use Host (server) name ... the FQDN = ${server_name}"
echo ""
set -x
sudo rm -fv /etc/tls/localcerts/${server_name}.key.orig
sudo rm -fv /etc/tls/localcerts/${server_name}.key
sudo rm -fv /etc/tls/localcerts/${server_name}.pem.orig
sudo rm -fv /etc/tls/localcerts/${server_name}.pem 
sudo rm -fv /etc/tls/localcerts/${server_name}.pfx
#
sudo rm -fv "./cert.input"
echo "AU">> "./cert.input"
echo "no-state">> "./cert.input"
echo "no-city">> "./cert.input"
echo "no-company">> "./cert.input"
echo "no-orgunit">> "./cert.input"
echo "${server_name}">> "./cert.input"
echo "noname@no-company.com">> "./cert.input"
echo "">> "./cert.input"
echo "">> "./cert.input"
sudo openssl req -x509 -nodes -days 12650 -newkey rsa:2048 -out /etc/tls/localcerts/${server_name}.pem -keyout /etc/tls/localcerts/${server_name}.key < "./cert.input"
sudo chmod -c a=rwx -R /etc/tls/localcerts/*
sudo rm -fv "./cert.input"
ls -al "/etc/tls/localcerts/"
set +x
echo ""
##read -p "Press Enter to continue #"
echo ""

echo "# Strip Out Passphrase from the Key"
set -x
sudo cp -fv /etc/tls/localcerts/${server_name}.pem /etc/tls/localcerts/${server_name}.pem.orig
sudo cp -fv /etc/tls/localcerts/${server_name}.key /etc/tls/localcerts/${server_name}.key.orig
sudo chmod -c a=rwx -R /etc/tls/localcerts/*
sudo openssl rsa -in /etc/tls/localcerts/${server_name}.key.orig -out /etc/tls/localcerts/${server_name}.key
sudo chmod -c a=rwx -R /etc/tls/localcerts/*
set +x
echo ""
##read -p "Press Enter to continue #"
echo ""

#Enter pass phrase for ${server_name}.key: Certificates
#You are about to be asked to enter information that will be incorporated
#into your certificate request.
#What you are about to enter is what is called a Distinguished Name or a DN.
#There are quite a few fields but you can leave some blank
#For some fields there will be a default value,
#If you enter '.', the field will be left blank.
#-----
#Country Name (2 letter code) [AU]:AU
#State or Province Name (full name) [Some-State]:anon
#Locality Name (eg, city) []:NoCity
#Organization Name (eg, company) [Internet Widgits Pty Ltd]:noname
#Organizational Unit Name (eg, section) []:noname
#Common Name (e.g. server FQDN or YOUR name) []:${server_name}
#Email Address []:heckle@gmail.com
#
#Please enter the following 'extra' attributes
#to be sent with your certificate request
#A challenge password []:
#An optional company name []:

echo "# Create the PKCS12 Certificate"
echo "# If we need a pk12 cert (eg for EMBY software) it requires a pkcs12 certificate to be generated, "
echo "#"
echo "#Convert PEM & Private Key to PFX/P12:"
echo ""
echo "When prompted for Export Password, just press Enter"
echo "When prompted for Export Password, just press Enter"
echo "When prompted for Export Password, just press Enter"
echo "When prompted for Export Password, just press Enter"
echo "When prompted for Export Password, just press Enter"
echo "When prompted for Export Password, just press Enter"
echo "When prompted for Export Password, just press Enter"
echo "When prompted for Export Password, just press Enter"
echo "When prompted for Export Password, just press Enter"
echo "When prompted for Export Password, just press Enter"
echo ""
set -x
sudo rm -fv "./cert.pass.input"
echo "">> "./cert.pass.input"
echo "">> "./cert.pass.input"
echo "">> "./cert.pass.input"
echo "">> "./cert.pass.input"
sudo openssl pkcs12 -export -out /etc/tls/localcerts/${server_name}.pfx -inkey /etc/tls/localcerts/${server_name}.key.orig -in /etc/tls/localcerts/${server_name}.pem <"./cert.pass.input"
sudo chmod -c a=rwx -R /etc/tls/localcerts/*
sudo rm -fv "./cert.pass.input"
set +x
echo ""

echo ""
echo "# In /etc/tls/localcerts we should now have"
echo "# ${server_name}.key.orig  original cert key with embedded (blank) Passphrase"
echo "# ${server_name}.pem.orig  original final certificate"
echo "# ${server_name}.key       cert key without embedded (blank) passphrase"
echo "# ${server_name}.pem       final certificate"
echo "# ${server_name}.pfx       the PKCS12 Certificate"
echo ""
set -x
ls -al "/etc/tls/localcerts/"
set +x
echo ""

# optional also  -certfile more.crt : This is optional, this is if you have any additional certificates you would like to include in the PFX file.
#You should be prompted in this order:
#   Loading 'screen' into random state - done
#   Enter pass phrase for filename.txt: (Enter the private key password)
#   Enter Export Password: (This will be the password for the new PKCS12 file)
#   Verifying - Enter Export Password: (Confirm the password)
#   unable to write 'random state' (If this this error appears, please ignore)

set -x
sudo chmod -c a=rwx -R /etc/tls/localcerts/*
set +x

echo ""
##read -p "Press Enter to continue, if the Certificates Setup worked"
echo ""


echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# Update Apache2 virtualhost configs"
echo ""
echo ""
echo "# Use a modified tls conf with all of the good stuff"
set -x
cd ~/Desktop
url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/setup_support_files/000-default.conf"
rm -f "./000-default.conf"
rm -f "./000-default.conf.old"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "./000-default.conf" --fail # -L means "allow redirection" or some odd :|
sudo cp -fv "./000-default.conf"  "./000-default.conf.old"
#
sudo sed -i "s;Pi4CC;${server_name};g"  "./000-default.conf"
sudo sed -i "s;/mnt/mp4library/mp4library;${server_root_folder};g"  "./000-default.conf"
sudo sed -i "s;/mnt/mp4library;${server_root_USBmountpoint};g"  "./000-default.conf"
sudo sed -i "s;mp4library;${server_alias};g"  "./000-default.conf"
#
sudo diff -U 1 "./000-default.conf.old" "./000-default.conf"
sudo mv -fv "./000-default.conf" "/etc/apache2/sites-available/000-default.conf"
set +x
echo ""
#
echo ""
echo "# Use a modified default conf with all of the good stuff"
set -x
cd ~/Desktop
url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/setup_support_files/default-tls.conf"
rm -f "./default-tls.conf"
rm -f "./default-tls.conf.old"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "./default-tls.conf" --fail # -L means "allow redirection" or some odd :|
sudo cp -fv "./default-tls.conf"  "./default-tls.conf.old"
#
sudo sed -i "s;Pi4CC;${server_name};g"  "./default-tls.conf"
sudo sed -i "s;/mnt/mp4library/mp4library;${server_root_folder};g"  "./default-tls.conf"
sudo sed -i "s;/mnt/mp4library;${server_root_USBmountpoint};g"  "./default-tls.conf"
sudo sed -i "s;mp4library;${server_alias};g"  "./default-tls.conf"
#
sudo diff -U 1 "./default-tls.conf.old" "./default-tls.conf"
sudo mv -fv "./default-tls.conf" "/etc/apache2/sites-available/default-tls.conf"
set +x
echo ""

echo ""
set -x
cd ~/Desktop
url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/setup_support_files/example.php"
rm -f "./example.php"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "./example.php" --fail # -L means "allow redirection" or some odd :|
sed -i.BAK "s;Pi4CC;${server_name};g" "./example.php"
sudo diff -U 1 "./example.php.BAK" "./example.php"
sudo mv -fv "./example.php" "/var/www/example.php"
set +x
echo ""

echo ""
set -x
cd ~/Desktop
url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/setup_support_files/phpinfo.php"
rm -f "./phpinfo.php"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "./phpinfo.php" --fail # -L means "allow redirection" or some odd :|
sed -i.BAK "s;Pi4CC;${server_name};g" "./phpinfo.php"
sudo diff -U 1 "./phpinfo.php.BAK" "./phpinfo.php"
sudo mv -fv "./phpinfo.php" "/var/www/phpinfo.php"
set +x
echo ""

#echo ""
##read -p "Press Enter to continue, if those downloads/moves worked"
#echo ""

echo ""
echo "# apache user, 'pi' ... Enter your normal password, then again"
echo "# apache user, 'pi' ... Enter your normal password, then again"
echo "# apache user, 'pi' ... Enter your normal password, then again"
echo "# apache user, 'pi' ... Enter your normal password, then again"
echo "# apache user, 'pi' ... Enter your normal password, then again"
echo "# apache user, 'pi' ... Enter your normal password, then again"
echo "# apache user, 'pi' ... Enter your normal password, then again"
echo "# apache user, 'pi' ... Enter your normal password, then again"
echo "# apache user, 'pi' ... Enter your normal password, then again"
echo "# apache user, 'pi' ... Enter your normal password, then again"
set -x
sudo htpasswd -c /usr/local/etc/apache_passwd pi
set +x
echo ""
echo "# At this point the folder /var/www/ still contains an index file something like index.html"
echo "# remove it so that we can do directory browsing from the root (it is handy)"
set -x
sudo rm /var/www/Index.*
sudo rm /var/www/index.*
set +x
echo ""
echo "Restart the Apache2 Service"
set -x
#sleep 3s
#systemctl restart apache2
sudo service apache2 restart
sleep 10s
set +x

echo ""
echo "# See if there were any Apache2 errors"
echo ""
set -x
#journalctl -xe # Press q to finish the listing
set +x
echo ""
##read -p "Press Enter to continue, if that all worked"
echo ""
set -x
cat /var/log/apache2/error.log
set +x
echo ""
##read -p "Press Enter to continue, if that all worked"
echo ""

sudo chown -c -R pi:www-data "/var/www"
sudo chmod -c a=rwx -R "/var/www"

echo ""
##read -p "Press Enter to continue, if that all worked"
echo ""


# Remotely connect to these to check things:
#http://$(server_ip)/server-status
#http://$(server_ip)/server-info
#http://$(server_ip)/phpinfo.php
#http://$(server_ip)/example.php


# Locally:

echo ""
set -x
curl --head 127.0.0.1
#
curl -I 127.0.0.1
set +x
echo "# Check for accept-ranges bytes etc"
echo "     Accept-Ranges: bytes"
echo "     Access-Control-Allow-Origin: *"
echo "     Access-Control-Allow-Headers: Allow-Origin, X-Requested-With, Content-Type, Accept"
echo ""
##read -p "Press Enter to continue, if that all worked and those are OK."
echo ""

set -x
curl 127.0.0.1/server-status
#set +x
##read -p "Press Enter to continue, if that worked."
#set -x
#curl 127.0.0.1/server-info
#set +x
##read -p "Press Enter to continue, if that worked."
#set -x
#curl 127.0.0.1/phpinfo.php
#set +x
##read -p "Press Enter to continue, if that worked."
#set -x
#curl 127.0.0.1/example.php
set +x
##read -p "Press Enter to continue, if that worked."
echo ""

echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALL minidlna"
echo "# ----------------"

# not strictly necessary to install, however it makes the server more "rounded" and accessible
# https://unixblogger.com/dlna-server-raspberry-pi-linux/
# https://www.youtube.com/watch?v=Vry0NpFjn5w
# https://www.deviceplus.com/how-tos/setting-up-raspberry-pi-as-a-home-media-server/

echo ""

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

echo "# Do the minidlna install"
set -x
sudo apt install -y minidlna
sleep 3s
#
sudo service minidlna stop
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
sudo diff -U 1 "/etc/minidlna.conf.old" "/etc/minidlna.conf"
set +x
echo ""

# after re-start, it looks for media
# force a re-scan at 4:00 am every night using crontab
# https://sourceforge.net/p/minidlna/discussion/879956/thread/41ae22d6/#4bf3
# To restart the service
#sudo service minidlna restart
set -x
sudo service minidlna stop
sleep 3s
#
ls -al "/run/minidlna"
#
sudo service minidlna start
sleep 10s
#
ls -al "/run/minidlna"
cat ${log_dir}/minidlna.log
cat "/var/log/minidlna.log"
#
sudo service minidlna force-reload
sleep 10s
#
cat ${log_dir}/minidlna.log
cat "/var/log/minidlna.log"
set +x

sh_file=${sh_dir}/minidlna_refresh.sh
log_file=${log_dir}/minidlna_refresh.log
#
sudo rm -vf "${log_file}"
touch "${log_file}"
#
sudo rm -vf "${sh_file}"
echo "#!/bin/bash" >> "${sh_file}"
echo "set -x" >> "${sh_file}"
echo "sudo service minidlna stop" >> "${sh_file}"
echo "sleep 10s" >> "${sh_file}"
echo "sudo service minidlna start" >> "${sh_file}"
echo "sleep 10s" >> "${sh_file}"
echo "sudo service minidlna force-reload" >> "${sh_file}"
echo "echo 'Wait 15 minutes for minidlna to index media files'" >> "${sh_file}"
echo "sleep 900s" >> "${sh_file}"
echo "set +x" >> "${sh_file}"

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

echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALL SAMBA"
echo "# -------------"
# https://magpi.raspberrypi.org/articles/raspberry-pi-samba-file-server
# https://pimylifeup.com/raspberry-pi-samba/

set -x
#sudo apt purge -y samba samba-common-bin
#sudo apt autoremove -y
#sudo rm -fv -fv "/etc/samba/smb.conf"
#
sudo apt install -y samba samba-common-bin
sudo apt install --reinstall -y samba samba-common-bin
set +x

echo ""
echo "Create a SAMBA password."
echo ""
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo " Before we start the server, you’ll want to set a Samba password. Enter you pi password."
set -x
sudo smbpasswd -a pi
sudo smbpasswd -a root
set +x
echo ""

echo ""
echo "Use a modified SAMBA conf with all of the good stuff"
url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/setup_support_files/smb.conf"
set -x
cd ~/Desktop
rm -f "./smb.conf"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "./smb.conf" --fail # -L means "allow redirection" or some odd :|
sudo cp -fv "./smb.conf"  "./smb.conf.old"
#---
##sudo sed -i "s;\[Pi\];\[Pi\];g"  "./smb.conf"
##sudo sed -i "s;\[Pi\];\[${server_name}\];g"  "./smb.conf"
sudo sed -i "s;comment=Pi4CC pi home;comment=${server_name} pi_home;g"  "./smb.conf"
##sudo sed -i "s;path = /home/pi;path = /home/pi;g"  "./smb.conf"
#---
sudo sed -i "s;\[mp4library\];\[${server_alias}\];g"  "./smb.conf"
sudo sed -i "s;comment=Pi4CC mp4library home;${server_name} ${server_alias} home;g"  "./smb.conf"
sudo sed -i "s;path = /mnt/mp4library;path = ${server_root_USBmountpoint};g"  "./smb.conf"
#---
##sudo sed -i "s;\[www\];\[www\];g"  "./smb.conf"
sudo sed -i "s;comment=Pi4CC www home;comment=${server_name} www home;g"  "./smb.conf"
##sudo sed -i "s;path = /var/www;path = /var/www;g"  "./smb.conf"
#---
sudo chmod -c a=rwx -R *
sudo diff -U 1 "./smb.conf.old" "./smb.conf"
sudo mv -fv "./smb.conf" "/etc/samba/smb.conf"
sudo chmod -c a=rwx -R "/etc/samba"
set +x
# ignore this: # rlimit_max: increasing rlimit_max (1024) to minimum Windows limit (16384)

echo ""
echo "Test the samba config is OK"
echo ""
set -x
sudo testparm
set +x

echo ""
echo "Restart Samba service"
set -x
sudo service smbd restart
sleep 10s
set +x

echo "List the new samba users (which can have different passwords to the Pi itself)"
set -x
sudo pdbedit -L -v
set +x

echo ""
echo "You can now access the defined shares from a Windows machine"
echo "or from an app that supports the SMB protocol"
echo "eg from Win10 PC in Windows Explorer use the IP address of ${server_name} like ... \\\\${server_ip}\\ "
set -x
hostname
hostname --fqdn
hostname --all-ip-addresses
set +x

echo ""
##read -p "Press Enter to continue, if that all worked"
echo ""


echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALL proftpd ftp server, connectable from filezilla"
echo "# (proftpd is more common than VSFTPD which has been superseded here)"
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo ""
set -x
cd ~/Desktop

set +x
echo "# ------------------------------------------------------------------------------------------------------------------------"
set -x
cd ~/Desktop
sudo apt purge -y proftpd proftpd-basic proftpd-mod-case proftpd-doc 
sudo chmod -c a=rwx -R "/etc/proftpd/proftpd.conf"
sudo rm -vf "/etc/proftpd/proftpd.conf"
#
sudo apt install -y proftpd proftpd-mod-case proftpd-doc 
sudo cat /var/log/proftpd/proftpd.log
set +x
#
# https://htmlpreview.github.io/?https://github.com/Castaglia/proftpd-mod_case/blob/master/mod_case.html
# Use directives
#  CaseIgnore on
#  LoadModule mod_case.c
# to enable case-insensitivity for all FTP commands handled by mod_case
# http://www.proftpd.org/docs/howto/ServerType.html
# http://www.proftpd.org/docs/howto/Stopping.html
#
# update the conf file
set -x
# http://www.proftpd.org/docs/howto/Stopping.html
# deny incoming connections - does not stop the ftp server
sudo ftpshut -l 0 -d 0 now
# now kill the daemon
kill -TERM `cat /run/proftpd.pid`
#
sudo rm -fv "/etc/proftpd/proftpd.conf.old"
sudo cp -fv "/etc/proftpd/proftpd.conf" "/etc/proftpd/proftpd.conf.old" 
rm -fv "./tmp.tmp"
cat<<EOF >"./tmp.tmp"
# Case Sensitive module at top
LoadModule mod_case.c
<IfModule mod_case.c>
CaseIgnore on
</IfModule>
EOF
sudo cat "/etc/proftpd/proftpd.conf">>"./tmp.tmp"
#
sudo sed -i "s;ServerName\t\t\t\"Debian\";ServerName\t\t\t\"Pi4CC\";g" "./tmp.tmp"
sudo sed -i "s;DisplayLogin;#DisplayLogin;g" "./tmp.tmp"
sudo sed -i "s;DisplayChdir;#DisplayChdir;g" "./tmp.tmp"
sudo sed -i "s;# RequireValidShell\t\toff;RequireValidShell\t\toff;g" "./tmp.tmp"
sudo sed -i "s;User\t\t\t\tproftpd;User\t\t\t\tpi;g" "./tmp.tmp"
sudo sed -i "s;Group\t\t\t\tnogroup;Group\t\t\t\tpi;g" "./tmp.tmp"
sudo sed -i "s;Umask\t\t\t\t022  022;Umask\t\t\t\t000  000;g" "./tmp.tmp"
#"/boot_delay/d"
sudo sed -i '/# Include other custom configuration files/d' "./tmp.tmp"
sudo sed -i '/Include \/etc\/proftpd\/conf.d\//d' "./tmp.tmp"
#
cat<<EOF >>"./tmp.tmp"
<Anonymous ~pi>
User pi
Group pi
UserAlias anonymous pi
RequireValidShell off
MaxClients 30
Umask 000 000
<Directory *>
Umask 000 000
<Limit WRITE>
AllowAll
</Limit>
</Directory>
</Anonymous>
# Include other custom configuration files
Include /etc/proftpd/conf.d/
EOF
#cat "./tmp.tmp"
#
sudo cp -fv "./tmp.tmp" "/etc/proftpd/proftpd.conf"
rm -f "./tmp.tmp"
diff -U 1 "/etc/proftpd/proftpd.conf.old" "/etc/proftpd/proftpd.conf"
#cat "/etc/proftpd/proftpd.conf"
#
sudo proftpd -vv
sudo proftpd -t -d5
sudo proftpd --list 
# re-enable server
sudo rm -fv "/etc/shutmsg"
sudo proftpd
set +x
##read -p "Press Enter to continue, if that all worked"
echo ""

echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALL the chromecast WEB pages and javascript and python code etc for ${server_alias} ${server_ip}"
echo ""

# get each file individually rather than the full package
set +x
cd ~/Desktop
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
copy_to_top reload_media.js.sh
#copy_to_top media.js
set +x

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
echo "   https://${server_name}/${server_ip}"
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
echo ""
echo ""
echo "Finished."
echo ""

exit


# ------------------------------------------------------------------------------------------------------------------------

# Yet to investigate:
#
# As at 2019.12.12
# 1. implement a "back 30 seconds" button
# 2. implement a "forward 30 seconds" button
# 3. implement a "stop" button
# 4. implement no autoplay upon media loading (a quick look shows "hard" code changes may be needed due to the way the app is coded)
# 5. perhaps re-implement using video.js ?  the google code seems VERY tightly bound to their web page though :(

Addendum:

## Documentation
* [Google Cast Chrome Sender Overview](https://developers.google.com/cast/docs/chrome_sender/)
* [Developer Guides](https://developers.google.com/cast/docs/developers)

## References
* [Chrome Sender Reference](http://developers.google.com/cast/docs/reference/chrome)
* [Design Checklist](http://developers.google.com/cast/docs/design_checklist)

## How to report bugs
* [Google Cast SDK Support](https://developers.google.com/cast/support)
* For sample app issues, open an issue on this GitHub repo.

## Terms
Your use of this sample is subject to, and by using or downloading the sample files you agree to comply with, the [Google APIs Terms of Service](https://developers.google.com/terms/) and the [Google Cast SDK Additional Developer Terms of Service](https://developers.google.com/cast/docs/terms/).



# SUPERSEDED:
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALL VSFTPD ftp server, connectable from filezilla"
echo "# -----------------------------------------------------"
echo ""

set -x 
sudo apt-get purge -y vsftpd
sudo chmod -c a=rwx -R "/etc/vsftpd.conf"
sudo rm -vf "/etc/vsftpd.conf"
sudo apt-get install -y vsftpd
set +x
#
# https://security.appspot.com/vsftpd/vsftpd_conf.html
# http://vsftpd.beasts.org/vsftpd_conf.html
# Remember
# local_umask ( 0011 ) is subtracted. 
# The umask essentially removes the permissions you don't want users to have, so use 000

set -x
# https://security.appspot.com/vsftpd/vsftpd_conf.html
sudo service vsftpd stop
sudo chmod -c a=rwx -R "/etc/vsftpd.conf"
sudo cp -fv "/etc/vsftpd.conf" "/etc/vsftpd.conf.backup"
sudo sed -i "s;listen=NO;listen=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;listen_ipv6=YES;listen_ipv6=NO;g" "/etc/vsftpd.conf"
sudo sed -i "s;anonymous_enable=NO;anonymous_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;local_enable=YES;write_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#local_umask=022;local_umask=000;g" "/etc/vsftpd.conf"
sudo sed -i "s;#anon_upload_enable=YES;anon_upload_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#anon_mkdir_write_enable=YES;anon_mkdir_write_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;use_localtime=YES;use_localtime=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;xferlog_enable=YES;xferlog_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#chown_uploads=YES;chown_uploads=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#chown_username=whoever;chown_username=pi;g" "/etc/vsftpd.conf"
sudo sed -i "s;#xferlog_std_format=YES;xferlog_std_format=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#idle_session_timeout=600;idle_session_timeout=1200;g" "/etc/vsftpd.conf"
sudo sed -i "s;#ftpd_banner=Welcome to blah FTP service.;ftpd_banner=${server_name} ftp service;g" "/etc/vsftpd.conf"
sudo sed -i "s;#chroot_local_user=YES;chroot_local_user=NO;g" "/etc/vsftpd.conf"
sudo sed -i "s;#ls_recurse_enable=YES;ls_recurse_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#xferlog_file=/var/log/vsftpd.log;xferlog_file=/var/log/vsftpd.log;g" "/etc/vsftpd.conf"
sudo sed -i "s;#utf8_filesystem=YES;utf8_filesystem=YES;g" "/etc/vsftpd.conf"
sudo echo "#" >> "/etc/vsftpd.conf"
sudo echo "## add our extra stuff" >> "/etc/vsftpd.conf"
sudo echo "anon_root=/home" >> "/etc/vsftpd.conf"
sudo echo "local_enable=YES" >> "/etc/vsftpd.conf"
sudo echo "allow_anon_ssl=YES" >> "/etc/vsftpd.conf"
sudo echo "anon_other_write_enable=YES" >> "/etc/vsftpd.conf"
sudo echo "delete_failed_uploads=YES" >> "/etc/vsftpd.conf"
sudo echo "dirlist_enable=YES" >> "/etc/vsftpd.conf"
sudo echo "download_enable=YES" >> "/etc/vsftpd.conf"
sudo echo "no_anon_password=YES" >> "/etc/vsftpd.conf"
sudo echo "force_dot_files=YES" >> "/etc/vsftpd.conf"
sudo echo "file_open_mode=0777" >> "/etc/vsftpd.conf"
sudo echo "ftp_username=pi" >> "/etc/vsftpd.conf"
sudo echo "guest_username=pi" >> "/etc/vsftpd.conf"
sudo echo "dual_log_enable=YES" >> "/etc/vsftpd.conf"
sudo echo "syslog_enable=NO" >> "/etc/vsftpd.conf"
sudo echo "vsftpd_log_file=/var/log/vsftpd.log" >> "/etc/vsftpd.conf"
sudo echo "log_ftp_protocol=YES" >> "/etc/vsftpd.conf"
sudo echo "allow_writeable_chroot=YES" >> "/etc/vsftpd.conf"
sudo diff -U 1 "/etc/vsftpd.conf.backup" "/etc/vsftpd.conf"
sudo service vsftpd restart
sleep 5s
sudo systemctl status vsftpd.service
sudo tail /var/log/syslog 
sudo tail /var/log/vsftpd.log
set +x
echo ""