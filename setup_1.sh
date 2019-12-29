#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# This will install some of the requisitive thuff, but not edit the config files etc

set -x
cd ~/Desktop

set +x
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
#server_name=Pi4cc
#server_alias=mp4library
#server_root=/mnt/mp4library
#server_root_folder=/mnt/mp4library/mp4library
#
server_name_default=Pi4cc
server_alias_default=mp4library
#server_root_USBmountpoint_default=/mnt/${server_alias_default}
#server_root_folder_default=${server_root_USBmountpoint_default}/${server_alias_default}
#
read -e -p "This server_name (will become name of website) [${server_name_default}]: " -i "${server_name_default}" input_string
server_name="${input_string:-$server_name_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
#
read -e -p "This server_alias (will become a Virtual Folder within the website) [${server_alias_default}]: " -i "${server_alias_default}" input_string
server_alias="${input_string:-$server_alias_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
#
server_root_USBmountpoint_default=/mnt/${server_alias}
read -e -p "Designate the mount point for the USB3 external hard drive [${server_root_USBmountpoint_default}]: " -i "${server_root_USBmountpoint_default}" input_string
server_root_USBmountpoint="${input_string:-$server_root_USBmountpoint_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
#
server_root_folder_default=${server_root_USBmountpoint}/${server_alias}
read -e -p "Designate the root folder on the USB3 external hard drive) [${server_root_folder_default}]: " -i "${server_root_folder_default}" input_string
server_root_folder="${input_string:-$server_root_folder_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
#
echo ""
echo "              server_name=${server_name}"
echo "             server_alias=${server_alias}"
echo "server_root_USBmountpoint=${server_root_USBmountpoint}"
echo "       server_root_folder=${server_root_folder}"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
set +x

echo "# Set permissions so we can do ANYTHING with the USB3 drive."
set -x
sudo chmod +777 -R ${server_root_USBmountpoint}
set +x

echo "# Check the exterrnal USB3 drive mounted where we told it to by doing a df"
set -x
df
set +x
read -p "Press Enter to continue"

echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALLING APACHE & PHP"
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
sleep 5s
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
sleep 5s
# REMOVE CONFIG FILES
sudo rm -fv "/etc/php/7.3/apache2/php.ini"
#read -p "Press Enter to continue #"
sudo rm -fv "/etc/apache2/apache2.conf"
#read -p "Press Enter to continue #"
sudo rm -fv "/etc/apache2/mods-available/status.conf"
#read -p "Press Enter to continue #"
sudo rm -fv "/etc/apache2/mods-available/info.conf"
#read -p "Press Enter to continue #"
sudo rm -fv "/etc/apache2/sites-available/000-default.conf"
#read -p "Press Enter to continue #"
sudo rm -fv "/etc/apache2/sites-available/default-tls.conf"
#read -p "Press Enter to continue #"
# INSTALL APACHE2
sudo apt install -y apache2 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y apache2-bin
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y apache2-data
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y apache2-utils
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y apache2-doc
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y apache2-suexec-pristine
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y apache2-ssl-dev
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y libxml2 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y libxml2-dev 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y libxml2-utils
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y libaprutil1 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y libaprutil1-dev
sleep 3s
#read -p "Press Enter to continue #"
# socache_dbm required for gnutls
sudo a2enmod socache_dbm
sleep 3s
sudo apt install -y libapache2-mod-gnutls 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y libapache2-mod-security2
sleep 3s
#read -p "Press Enter to continue #"
# Note: the version lile 7.3 will change as time passes !!!!!!!
# INSTALL PHP
sudo apt install -y php7.3 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-common 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-cli 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-intl 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-curl 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-xsl 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-gd 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-recode 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-tidy 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-json 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-mbstring 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-dev 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-bz2 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php7.3-zip 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y php-pear 
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y libmcrypt-dev
sleep 3s
#read -p "Press Enter to continue #"
sudo apt install -y libapache2-mod-php
sleep 3s
#read -p "Press Enter to continue #"
set +x

echo ""
read -p "Press Enter to continue, if it installed correctly"

echo "Make changes to /etc/php/7.3/apache2/php.ini"
set -x
sudo cp -fv "/etc/php/7.3/apache2/php.ini" "/etc/php/7.3/apache2/php.ini.old"
sudo sed -i 's;max_execution_time = 30;max_execution_time = 300;g'          "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's;max_input_time = 60;max_input_time = 300;g'                  "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's;display_errors = Off;display_errors = On;g'                  "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's;display_startup_errors = Off;display_startup_errors = On;g'  "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's;log_errors_max_len = 1024;log_errors_max_len = 8192;g'       "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's;default_socket_timeout = 60;default_socket_timeout = 300;g'  "/etc/php/7.3/apache2/php.ini"
diff -U 1 "/etc/php/7.3/apache2/php.ini.old" "/etc/php/7.3/apache2/php.ini"
php -version
set +x

echo ""
read -p "Press Enter to continue, if it there were 6 changes correctly"

echo "# Install python3"
set -x
#sudo apt purge -y python3 idle
sudo apt purge -y libapache2-mod-python
sudo apt autoremove -y
sleep 5s
#
sudo apt install -y python3 
sudo apt install -y idle
sleep 3s
sudo apt install -y libapache2-mod-python
sleep 3s
set +x
read -p "Press Enter to continue, if it worked correctly"

echo ""
echo "# OK, finished Apache2/Python3/PSH APT installs"

echo ""
echo "# Setup some handy protections"
set -x
sudo groupadd -f www-data
sudo usermod -a -G www-data root
sudo usermod -a -G www-data pi
sudo chown -R -f pi:www-data /var/www
sudo chmod +777 -R /var/www
sleep 3s
cat /var/log/apache2/error.log
ls -al /etc/apache2/sites-enabled
ls -al /etc/apache2/sites-available
set +x
#read -p "Press Enter to continue, if it worked correctly"

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
sudo a2dismod ssl
sudo a2enmod gnutls
sudo a2enmod php7.3
sudo a2enmod python
sudo a2enmod xml2enc
sudo a2enmod alias 
sudo a2enmod cgi
sleep 3s
set +x
#read -p "Press Enter to continue, if it worked correctly"

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
echo '#ServerRoot "/etc/apache2'
echo "## add this line to say the web server name is going to be ${server_name}"
echo "ServerName ${server_name}"
set -x
sudo cp -fv "/etc/apache2/apache2.conf" "/etc/apache2/apache2.conf.old"
sudo sed -i 's;#ServerRoot;#ServerRoot\nServerName ${server_name};g' "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's;Timeout 300;Timeout 10800;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;MaxKeepAliveRequests 100;MaxKeepAliveRequests 0;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;KeepAliveTimeout 5;KeepAliveTimeout 10800;g' "/etc/apache2/apache2.conf"
# in reverse order
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nCheckCaseOnly On;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nCheckSpelling On;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nHeader set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept";g' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nHeader set Access-Control-Allow-Origin "*";g' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nHeader set Accept-Ranges bytes;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nMaxRangeReversals unlimited;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nMaxRangeOverlaps unlimited;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nMaxRanges unlimited;g' "/etc/apache2/apache2.conf"
# in reverse order
sudo sed -i 's;Include ports.conf;Include ports.conf\nCheckCaseOnly On;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nCheckSpelling On;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nHeader set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept";g' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nHeader set Access-Control-Allow-Origin "*";g' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nHeader set Accept-Ranges bytes;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nMaxRangeReversals unlimited;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nMaxRangeOverlaps unlimited;g' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nMaxRanges unlimited;g' "/etc/apache2/apache2.conf"
# these don't occur in this file, however try anyway
sudo sed -i "s;Pi4CC;${server_name};g"  "/etc/apache2/apache2.conf"
sudo sed -i "s;/mnt/mp4library/mp4library;${server_root_folder};g"  "/etc/apache2/apache2.conf"
sudo sed -i "s;/mnt/mp4library;${server_root_USBmountpoint};g"  "/etc/apache2/apache2.conf"
sudo sed -i "s;mp4library;${server_alias};g"  "/etc/apache2/apache2.conf"
#
diff -U 1 "/etc/apache2/apache2.conf.old" "/etc/apache2/apache2.conf"
set +x

echo ""
#read -p "Press Enter to continue, if the all of the apache2.conf worked correctly"
echo ""

echo '# Under the "Location /server-status" directive, '
echo '# Locate the "#Require ip 192.0.2.0/24" '
echo "# line and add a lind underneath for yout lan segment change"
echo "# of a the tablet or equipment on the LAN "
echo "# which you will be using to access the web server,"
echo ""
set -x
sudo cp -fv "/etc/apache2/mods-available/status.conf" "/etc/apache2/mods-available/status.conf.old"
sudo sed -i 's;#Require ip 192.0.2.0/24;#Require ip 192.0.2.0/24\n#Require ip 127.0.0.1\n#Require ip 192.168.108.133/24\n#Require ip 10.0.0.1/24;g' "/etc/apache2/mods-available/status.conf"
diff -U 1 "/etc/apache2/mods-available/status.conf.old" "/etc/apache2/mods-available/status.conf"
set +x
echo ""
#read -p "Press Enter to continue, if the status.conf worked correctly"
echo ""

set -x
sudo cp -fv "/etc/apache2/mods-available/info.conf" "/etc/apache2/mods-available/info.conf.old"
sudo sed -i 's;#Require ip 192.0.2.0/24;#Require ip 192.0.2.0/24\n#Require ip 127.0.0.1\n#Require ip 192.168.108.133/24\n#Require ip 10.0.0.1/24;g' "/etc/apache2/mods-available/info.conf"
diff -U 1 "/etc/apache2/mods-available/info.old" "/etc/apache2/mods-available/info."
set +x
echo ""
#read -p "Press Enter to continue, if the info.conf worked correctly"
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
read -p "Press Enter to continue, if setting the sites worked correctly"
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
echo "Use Host (server) name FQDN = ${server_name}"
echo "Use Host (server) name FQDN = ${server_name}"
echo ""
set -x
sudo openssl req -x509 -nodes -days 12650 -newkey rsa:2048 -out /etc/tls/localcerts/${server_name}.pem -keyout /etc/tls/localcerts/${server_name}.key
ls -al "/etc/tls/localcerts/"
set +x
echo ""
#read -p "Press Enter to continue #"
echo ""

echo "# Strip Out Passphrase from the Key"
set -x
cp /etc/tls/localcerts/${server_name}.pem /etc/tls/localcerts/${server_name}.pem.orig
cp /etc/tls/localcerts/${server_name}.key /etc/tls/localcerts/${server_name}.key.orig
openssl rsa -in /etc/tls/localcerts/${server_name}.key.orig -out /etc/tls/localcerts/${server_name}.key
sudo chmod 600 /etc/tls/localcerts/*
set +x
echo ""
#read -p "Press Enter to continue #"
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

echo ""
echo "# In /etc/tls/localcerts we should now have"
echo "# ${server_name}.key.orig  cert key with embedded Passphrase"
echo "# ${server_name}.key       cert key"
echo "# ${server_name}.pem       final certificate"
echo ""
set -x
ls -al "/etc/tls/localcerts/"
set +x
echo ""
read -p "Press Enter to continue, if that worked"
echo ""

echo "# Create the PKCS12 Certificate"
echo "# If we need a pk12 cert (eg for EMBY software) it requires a pkcs12 certificate to be generated, "
echo "#"
echo "#Convert PEM & Private Key to PFX/P12:"
set -x
sudo openssl pkcs12 -export -out /etc/tls/localcerts/${server_name}.pfx -inkey /etc/tls/localcerts/${server_name}.key.orig -in /etc/tls/localcerts/${server_name}.pem 
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
sudo chmod 777 /etc/tls/localcerts/*
set +x

echo ""
read -p "Press Enter to continue, if that worked"
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
rm -f "000-default.conf"
rm -f "000-default.conf.old"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "000-default.conf" --fail # -L means "allow redirection" or some odd :|
cp -fv "000-default.conf"  "000-default.conf.old"
#
sudo sed -i "s;Pi4CC;${server_name};g"  "000-default.conf"
sudo sed -i "s;/mnt/mp4library/mp4library;${server_root_folder};g"  "000-default.conf"
sudo sed -i "s;/mnt/mp4library;${server_root_USBmountpoint};g"  "000-default.conf"
sudo sed -i "s;mp4library;${server_alias};g"  "000-default.conf"
#
diff -U 1 "000-default.conf.old" "000-default.conf"
sudo mv -fv "000-default.conf" "/etc/apache2/sites-available/000-default.conf"
set +x
echo ""
#
echo ""
echo "# Use a modified default conf with all of the good stuff"
set -x
cd ~/Desktop
url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/setup_support_files/default-tls.conf"
rm -f "default-tls.conf"
rm -f "default-tls.conf.old"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "default-tls.conf" --fail # -L means "allow redirection" or some odd :|
cp -fv "default-tls.conf"  "default-tls.conf.old"
#
sudo sed -i "s;Pi4CC;${server_name};g"  "default-tls.conf"
sudo sed -i "s;/mnt/mp4library/mp4library;${server_root_folder};g"  "default-tls.conf"
sudo sed -i "s;/mnt/mp4library;${server_root_USBmountpoint};g"  "default-tls.conf"
sudo sed -i "s;mp4library;${server_alias};g"  "default-tls.conf"
#
diff -U 1 "default-tls.conf.old" "default-tls.conf"
sudo mv -fv "default-tls.conf" "/etc/apache2/sites-available/default-tls.conf"
set +x
echo ""

echo ""
set -x
cd ~/Desktop
url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/setup_support_files/example.php"
rm -f "example.php"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "example.php" --fail # -L means "allow redirection" or some odd :|
sed -iBAK "s;Pi4CC;${server_name};g" "example.php"
diff -U 1 "example.BAK" "example.php"
sudo mv -fv "example.php" "/var/www/example.php"
set +x
echo ""

echo ""
set -x
cd ~/Desktop
url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/setup_support_files/phpinfo.php"
rm -f "phpinfo.php"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "phpinfo.php" --fail # -L means "allow redirection" or some odd :|
sed -iBAK "s;Pi4CC;${server_name};g" "phpinfo.php"
diff -U 1 "phpinfo.BAK" "phpinfo.php"
sudo mv -fv "phpinfo.php" "/var/www/phpinfo.php"
set +x
echo ""

#echo ""
#read -p "Press Enter to continue, if those downloads/moves worked"
#echo ""

echo ""
echo "# add an apache user, 'pi', enter your-intended-password twice"
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
sleep 3s
#systemctl restart apache2
sudo service apache2 restart
sleep 10s
set +x

echo ""
echo "# See if there were any Apache2 errors"
echo ""
set -x
journalctl -xe
set +x
echo ""
read -p "Press Enter to continue, if that all worked"
echo ""
#set -x
#cat /var/log/apache2/error.log
#set +x
#echo ""
#read -p "Press Enter to continue, if that all worked"
#echo ""

echo ""
read -p "Press Enter to continue, if that all worked"
echo ""


# Remotely connect to these to check things:
#http://10.0.0.6/server-status
#http://10.0.0.6/server-info
#http://10.0.0.6/phpinfo.php
#http://10.0.0.6/example.php


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
read -p "Press Enter to continue, if that all worked and those are OK."
echo ""

set -x
curl 127.0.0.1/server-status
set +x
read -p "Press Enter to continue, if that worked."
set -x
curl 127.0.0.1/server-info
set +x
read -p "Press Enter to continue, if that worked."
set -x
curl 127.0.0.1/phpinfo.php
set +x
read -p "Press Enter to continue, if that worked."
set -x
curl 127.0.0.1/example.php
set +x
read -p "Press Enter to continue, if that worked."
echo ""


echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALL miniDLNA"
echo "# ----------------"

# not strictly necessary to install, however it makes the server more "rounded" and accessible
# https://unixblogger.com/dlna-server-raspberry-pi-linux/
# https://www.youtube.com/watch?v=Vry0NpFjn5w
# https://www.deviceplus.com/how-tos/setting-up-raspberry-pi-as-a-home-media-server/

echo ""

set -x
sudo apt purge minidlna -y
sudo apt autoremove -y
sleep 5s
sudo rm -vf "/etc/minidlna.conf"
set +x
echo ""

echo "# Create a folder for miniDLNA logs and db - place the folder in the root of the (fast) USB3 drive"
set -x
sudo mkdir -p "${server_root_USBmountpoint}/miniDLNA"
sudo chmod +777 -R "${server_root_USBmountpoint}/miniDLNA"
set +x
echo ""

echo "# Do the miniDLNA install"
set -x
sudo apt install -y minidlna
set +x

echo ""
echo "# Change miniDLNA config settings to look like these"
echo ""
set -x
sudo cp -fv "/etc/minidlna.conf" "/etc/minidlna.conf.old"
sudo sed -i 's;#user=minidlna;#user=minidlna\nuser=pi;g' "/etc/minidlna.conf"
sudo sed -i 's;media_dir=/var/lib/minidlna;#media_dir=/var/lib/minidlna\nmedia_dir=PV,${server_root_folder};g' "/etc/minidlna.conf"
sudo sed -i 's;#db_dir=/var/cache/minidlna;#db_dir=/var/cache/minidlna\ndb_dir=${server_root_USBmountpoint}/miniDLNA;g' "/etc/minidlna.conf"
sudo sed -i 's;#log_dir=/var/log;#log_dir=/var/log\nlog_dir=${server_root_USBmountpoint}/miniDLNA;g' "/etc/minidlna.conf"
sudo sed -i 's;#friendly_name=;#friendly_name=\nfriendly_name=${server_name}-miniDLNA;g' "/etc/minidlna.conf"
sudo sed -i 's;#inotify=yes;#inotify=yes\ninotify=yes;g' "/etc/minidlna.conf"
sudo sed -i 's;#strict_dlna=no;#strict_dlna=no\nstrict_dlna=yes;g' "/etc/minidlna.conf"
sudo sed -i 's;#notify_interval=895;#notify_interval=895\nnotify_interval=300;g' "/etc/minidlna.conf"
sudo sed -i 's;#max_connections=50;#max_connections=50\nmax_connections=4;g' "/etc/minidlna.conf"
sudo sed -i 's;#log_level=general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn;#log_level=general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn\nlog_level=artwork,database,general,http,inotify,metadata,scanner,ssdp,tivo=info;g' "/etc/minidlna.conf"
diff -U 1 "/etc/minidlna.conf.old" "/etc/minidlna.conf"
sudo service minidlna restart
set +x
echo ""

# after re-start, it looks for media
# force a re-scan at 4:00 am every night using crontab
# https://sourceforge.net/p/minidlna/discussion/879956/thread/41ae22d6/#4bf3
set -x
sudo /usr/bin/killall minidlna
sleep 10s
sudo /usr/sbin/minidlna -R
sleep 3600s
sudo /usr/bin/killall minidlna
sleep 10s
sudo /usr/sbin/minidlna
set +x

read -p "Press Enter to continue, if the seds and service restart worked."
echo ""

exit


Then run crontab -e and add the following:
#    <minute> <hour> <day> <month> <dow> <tags and command>
#    <@freq> <tags and command>
0 4 * * * /usr/scripts/minidlna_refresh.sh > /usr/scripts/minidlna_refresh.log

# The MiniDLNA service comes with a small webinterface. 
# This webinterface is just for informational purposes. 
# You will not be able to configure anything here. 
# However, it gives you a nice and short information screen how many files have been found by MiniDLNA. 
# MiniDLNA comes with it’s own webserver integrated. 
# This means that no additional webserver is needed in order to use the webinterface.
# To access the webinterface, open your browser of choice and enter 
http://10.0.0.6:8200

# The actual streaming process
# A short overview how a connection from a client to the configured and running MiniDLNA server could work. 
# In this scenario we simply use a computer which is in the same local area network than the server. 
# As the client software we use the Video Lan Client (VLC). 
# Simple, robust, cross-platform and open source. 
# After starting VLC, go to the playlist mode by pressing CTRL+L in windows. 
# You will now see on the left side a category which is called Local Network. 
# Click on Universal Plug’n’Play which is under the Local Network category. 
# You will then see a list of available DLNA service within your local network. 
# In this list you should see your DLNA server. 
# Navigate through the different directories for music, videos and pictures and select a file to start the streaming process
#
# ------------------------------------------------------------------------------------------------------------------------
# INSTALL SAMBA
# -------------
# https://magpi.raspberrypi.org/articles/raspberry-pi-samba-file-server
# https://pimylifeup.com/raspberry-pi-samba/


sudo apt -y update
sudo apt -y upgrade
sudo apt purge -y samba samba-common-bin
sudo apt install -y samba samba-common-bin

#Create a password
#Before we start the server, you’ll want to set a Samba password. Enter:
sudo smbpasswd -a pi
sudo smbpasswd -a root

sudo cp /etc/samba/smb.conf /etc/samba/smb.conf_backup
sudo nano /etc/samba/smb.conf

sudo cp /etc/samba/smb.conf /etc/samba/smb.conf_backup
sudo nano /etc/samba/smb.conf
# https://calomel.org/samba_optimize.html
# https://calomel.org/samba.html
# find and change/add lines etc to make this outcome:

[global]
	# add these
    hosts 10.0.0.0/255.255.255.0 127.0.0.1
    security = user
    deadtime = 15
    #socket options = IPTOS_LOWDELAY TCP_NODELAY SO_RCVBUF=65536 SO_SNDBUF=65536 SO_KEEPALIVE
    # linux auto tunes SO_RCVBUF=65536 SO_SNDBUF=65536
    socket options = IPTOS_LOWDELAY TCP_NODELAY  SO_KEEPALIVE
    inherit permissions = yes
    # OK ... 1 is a sticky bit
    # create mask and directory mask REMOVE permissions
    #   create mask = 0777
    #   directory mask = 0777
    # force create mode and force directory mode 
    # specifies a set of UNIX mode bit permissions that will always be set 
    force create mode = 1777
    force directory mode = 1777
    #   valid users = %S
    # my stuff
    preferred master = No
    local master = No
    guest ok = yes
    browseable = yes
    #guest account = root
    guest account = pi
    #valid users = @users
	public = yes

# ADD THESE
[Pi]
comment=${server_name} pi_home
#force group = users
#guest only = Yes
guest ok = Yes
public = yes
#valid users = @users
path = /home/pi
available = yes
read only = no
browsable = yes
writeable = yes
#create mask = 0777
#directory mask = 0777
force create mode = 1777
force directory mode = 1777
inherit permissions = yes

[${server_alias}]
comment=${server_name} ${server_alias}
#force group = users
#guest only = Yes
guest ok = Yes
public = yes
#valid users = @users
path = ${server_root_USBmountpoint}
available = yes
read only = no
browsable = yes
writeable = yes
#create mask = 0777
#directory mask = 0777
force create mode = 1777
force directory mode = 1777
inherit permissions = yes

[www]
comment=${server_root_USBmountpoint} www_home
#force group = users
#guest only = Yes
guest ok = Yes
public = yes
#valid users = @users
path = /var/www
available = yes
read only = no
browsable = yes
writeable = yes
#create mask = 0777
#directory mask = 0777
force create mode = 1777
force directory mode = 1777
inherit permissions = yes

#control O
#control X

# Test the samba config is OK
sudo testparm

# ???????????????? ignore this
#rlimit_max: increasing rlimit_max (1024) to minimum Windows limit (16384)

# Restart Samba using
sudo service smbd restart

# List the new samba users, which can have different passwords to the Pi itself
sudo pdbedit -L -v

# You can now access the defined shares from a Windows machine 
# or from an app that supports the SMB protocol
# eg from Windows Explorer use address \\10.0.0.6\

# ------------------------------------------------------------------------------------------------------------------------
#
# "walk" the ${server_alias} in our browser
# ------------------------------------
#
# Use a chrome browser to check if it is working.
# Navigate to the ${server_alias} of the Pi web server 
# by typing the following into your web browser using your Pi's IP address
# http://10.0.0.6/${server_alias}
# and we should be able to navigate the ${server_alias} folder tree
#
# To copy .mp4 files to/from the Pi via SAMBA (file shares) -
# From a Windows 7 PC, use Windows Explorer to open a share on 
# the Pi using its IP address, put it in the address bar of Windows Explorer
# \\10.0.0.6\
# and see a number of shares including
#    ${server_alias}
#    www
# Open the ${server_alias} share. See the files and folders there.
# We can copy files to/from it just like any other windows folders.

# ------------------------------------------------------------------------------------------------------------------------

# Setup the ${server_name} website for chromecasting
#
# setup ready for the pything script
sudo apt install -y mediainfo
pip3 install pymediainfo

# which contains a web page for local LAN access and control of casting, if not using a 3rd party app
# as well as the python3 app to regenerate 

# create the ${server_name} folder inside Apache2 folder
sudo mkdir /var/www/${server_name}
sudo chown -R -f pi:www-data /var/www/${server_name}
sudo chmod +777 -R /var/www/${server_name}

# Copy the ${server_name} folder/file tree from github into this folder 
#   /var/www/${server_name}
# (samba can be handy for that)

# RE-CREATE the essential JSON file used by the ${server_name} website
# Invoke this script manually from the commandline like
python3 /var/www/${server_name}/2019.12.10-create-json.py --source_folder "${server_root_folder}" --filename-extension mp4 --json_file /var/www/${server_name}/media.js > /var/www/${server_name}/create-json.log 2>&1

#Run crontab with the -e flag to edit the cron table:
#crontab -e
#Select an editor
#The first time you run crontab you'll be prompted to select an editor; if you are not sure which one to use, choose nano by pressing Enter.
#Add a scheduled task
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
#For example:
#0 0 * * *  /home/pi/backup.sh
# If you want your command to be run in the background while the Raspberry Pi continues starting up, add a space and & at the end of the line, like this:
# @reboot python /home/pi/myscript.py &
#

# Run crontab -e and add the lines after, under user pi so it reloads media.js every night
crontab -e
@reboot python3 /var/www/${server_name}/2019.12.10-create-json.py --source_folder ${server_root_folder} ---filename-extension mp4 --json_file /var/www/${server_name}/media.js > /var/www/${server_name}/create-json.log 2>&1 &
0 4 * * * python3 /var/www/${server_name}/2019.12.10-create-json.py --source_folder ${server_root_folder} ---filename-extension mp4 --json_file /var/www/${server_name}/media.js > /var/www/${server_name}/create-json.log 2>&1

#View your currently saved scheduled tasks with:
crontab -l

# Visit the web page from a different PC to see if it all works:
https://10.0.0.6/${server_name}
# You may need to accept that the self-signed security certificate is "insecure" (cough, it is, it's solely inside your LAN)
# and allow it (proceed to "unsafe" website anyway)
# If you like, in Chrome browser, "hamburger" -> More Tools -> Developer Tools an watch the instrumentation log fly along (don't).


# How to use the website site https://10.0.0.6/${server_name}
# --------------------------------------------------
# Notes:
# 1. https: is "required" to cast videos to chromecast devices
# 2. All of the javascript runs on the client-side (i.e in the user browser)
# 3. The web page uses native HTML5 "<details> for drop-down lists
# 4. On a tablet or PC, open web page https://10.0.0.6/${server_name} IN A CHROME BROWSER ONLY
# 5. Click on a folder to see it drop down and display its list of .mp4 files
# 6. Click on a .mp4 file to load it into the browser
# 7. Check its the one you want, pause it, cast it to a chromecast device
# 8. Control playback via the web page
#

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