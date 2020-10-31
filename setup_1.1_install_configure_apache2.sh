#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# Build and configure HD-IDLE
# Call this .sh like:
# . "./setup_1.1_install_configure_apache2.sh"
#
set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALLING APACHE2 & PHP"
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
sudo diff -U 10 "/etc/php/7.3/apache2/php.ini.old" "/etc/php/7.3/apache2/php.ini"
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
sudo sed -i "s;#ServerRoot \"/etc/apache2\";#ServerRoot \"/etc/apache2\"\nServerName ${server_name};g" "/etc/apache2/apache2.conf"
sudo sed -i "s;Timeout 300;Timeout 10800;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;MaxKeepAliveRequests 100;MaxKeepAliveRequests 0;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;KeepAliveTimeout 5;KeepAliveTimeout 10800;g" "/etc/apache2/apache2.conf"
# in reverse order
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nCheckCaseOnly On;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nCheckSpelling On;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nHeader set Access-Control-Allow-Headers \"Allow-Origin, X-Requested-With, Content-Type, Accept\";g" "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nHeader set Access-Control-Allow-Origin \"*\";g" "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nHeader set Accept-Ranges bytes;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nMaxRangeReversals unlimited;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nMaxRangeOverlaps unlimited;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;HostnameLookups Off;HostnameLookups Off\nMaxRanges unlimited;g" "/etc/apache2/apache2.conf"
# in reverse order
sudo sed -i "s;Include ports.conf;Include ports.conf\nCheckCaseOnly On;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;Include ports.conf;Include ports.conf\nCheckSpelling On;g" "/etc/apache2/apache2.conf"
sudo sed -i "s;Include ports.conf;Include ports.conf\nHeader set Access-Control-Allow-Headers \"Allow-Origin, X-Requested-With, Content-Type, Accept\";g" "/etc/apache2/apache2.conf"
sudo sed -i "s;Include ports.conf;Include ports.conf\nHeader set Access-Control-Allow-Origin \"*\";g" "/etc/apache2/apache2.conf"
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
sudo diff -U 10 "/etc/apache2/apache2.conf.old" "/etc/apache2/apache2.conf"
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
sudo diff -U 10 "/etc/apache2/mods-available/status.conf.old" "/etc/apache2/mods-available/status.conf"
set +x
echo ""
##read -p "Press Enter to continue, if the status.conf worked correctly"
echo ""

set -x
sudo cp -fv "/etc/apache2/mods-available/info.conf" "/etc/apache2/mods-available/info.conf.old"
sudo sed -i "s;#Require ip 192.0.2.0/24;#Require ip 192.0.2.0/24\n#Require ip 127.0.0.1\n#Require ip ${server_ip}/24;g" "/etc/apache2/mods-available/info.conf"
sudo diff -U 10 "/etc/apache2/mods-available/info.conf.old" "/etc/apache2/mods-available/info.conf"
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
#sudo a2ensite 000-default
sudo a2dissite 000-default
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
sudo diff -U 10 "./000-default.conf.old" "./000-default.conf"
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
sudo diff -U 10 "./default-tls.conf.old" "./default-tls.conf"
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
sudo diff -U 10 "./example.php.BAK" "./example.php"
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
sudo diff -U 10 "./phpinfo.php.BAK" "./phpinfo.php"
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
# test the config
sudo apachectl configtest
# restart apache2
sudo systemctl restart apache2
#sudo service apache2 restart
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
echo "# ------------------------------------------------------------------------------------------------------------------------"
