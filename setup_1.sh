#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# This will install some of the requisitive thuff, but not edit the config files etc

set +x

echo "# Set permissions so we can do ANYTHING with the USB3 drive."
set -x
sudo chmod +777 /mnt/mp4library
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
sudo apt install -y apache2 
sudo apt install -y apache2-bin
sudo apt install -y apache2-data
sudo apt install -y apache2-utils
sudo apt install -y apache2-doc
sudo apt install -y apache2-suexec-pristine
sudo apt install -y apache2-ssl-dev
sudo apt install -y libxml2 libxml2-dev libxml2-utils
sudo apt install -y libaprutil1 libaprutil1-dev
# socache_dbm required for gnutls
sudo a2enmod socache_dbm
sudo apt install -y libapache2-mod-gnutls 
sudo apt install -y libapache2-mod-security2
# Note: the version lile 7.3 will change as time passes !!!!!!!
sudo apt install -y php7.3 php7.3-common php7.3-cli php7.3-intl php7.3-curl php7.3-xsl php7.3-gd 
sudo apt install -y php7.3-recode php7.3-tidy php7.3-json php7.3-mbstring php7.3-dev php7.3-bz2 php7.3-zip php-pear 
sudo apt install -y libmcrypt-dev
sudo apt install -y libapache2-mod-php
set +x

echo ""
read -p "Press Enter to continue, if it installed correctly"

echo "Make changes to /etc/php/7.3/apache2/php.ini"
set -x
sudo cp -fv "/etc/php/7.3/apache2/php.ini" "/etc/php/7.3/apache2/php.ini.old"
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/'          "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's/max_input_time = 60/max_input_time = 300/'                  "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's/display_errors = Off/display_errors = On/'                  "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's/display_startup_errors = Off/display_startup_errors = On/'  "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's/log_errors_max_len = 1024/log_errors_max_len = 8192/'       "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's/default_socket_timeout = 60/default_socket_timeout = 300/'  "/etc/php/7.3/apache2/php.ini"
diff -u "/etc/php/7.3/apache2/php.ini.old" "/etc/php/7.3/apache2/php.ini"
php -version
set +x

echo ""
read -p "Press Enter to continue, if it there were 6 changes correctly"

echo "#Install python3"
set -x
sudo apt install -y python3 idle
sudo apt install -y libapache2-mod-python
set +x
read -p "Press Enter to continue, if it worked correctly"

echo "# ok, finished Apache2/Python3/PSH APT installs"

echo "# Setup some handy protections"
set -x
sudo apt autoremove -y
sudo groupadd -f www-data
sudo usermod -a -G www-data root
sudo usermod -a -G www-data pi
sudo chown -R -f pi:www-data /var/www
sudo chmod +777 -R /var/www
cat /var/log/apache2/error.log
ls -al /etc/apache2/sites-enabled
ls -al /etc/apache2/sites-available
set +x
read -p "Press Enter to continue, if it worked correctly"

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
set +x
read -p "Press Enter to continue, if it worked correctly"

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
echo "## add this line to say the web server name is going to be Pi4CC"
echo "ServerName Pi4CC"
set -x
sudo cp -fv "/etc/apache2/apache2.conf" "/etc/apache2/apache2.conf.old"
sudo sed -i 's;#ServerRoot "/etc/apache2";ServerName Pi4CC\n#ServerRoot "/etc/apache2";'  "/etc/php/7.3/apache2/php.ini"
sudo sed -i 's;Timeout 300;Timeout 10800;' "/etc/apache2/apache2.conf"
sudo sed -i 's;MaxKeepAliveRequests 100;MaxKeepAliveRequests 0;' "/etc/apache2/apache2.conf"
sudo sed -i 's;KeepAliveTimeout 5;KeepAliveTimeout 10800;' "/etc/apache2/apache2.conf"
# in reverse order
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nCheckCaseOnly On;' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nCheckSpelling On;' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nHeader set Accept-Ranges bytes;' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nMaxRangeReversals unlimited;' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nMaxRangeOverlaps unlimited;' "/etc/apache2/apache2.conf"
sudo sed -i 's;HostnameLookups Off;HostnameLookups Off\nMaxRanges unlimited;' "/etc/apache2/apache2.conf"
# in reverse order
sudo sed -i 's;Include ports.conf;Include ports.conf\nCheckCaseOnly On;' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nCheckSpelling On;' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nHeader set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept";' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nHeader set Access-Control-Allow-Origin "*";' "/etc/apache2/apache2.conf"
sudo sed -i 's;Include ports.conf;Include ports.conf\nHeader set Accept-Ranges bytes;' "/etc/apache2/apache2.conf"
diff -u "/etc/apache2/apache2.conf.old" "/etc/apache2/apache2.conf"
set +x

echo ""
read -p "Press Enter to continue, if the all of the apache2.conf sed worked correctly"
echo ""

echo '# Under the "Location /server-status" directive, '
echo '# Locate the "#Require IP 192.0.2.0/24" '
echo "# line and add a lind underneath for yout lan segment change"
echo "# of a the tablet or equipment on the LAN "
echo "# which you will be using to access the web server,"
echo ""
set -x
sudo cp -fv "/etc/apache2/mods-available/status.conf" "/etc/apache2/mods-available/status.conf.old"
sed -i 's;#Require IP 192.0.2.0/24;#Require IP 192.0.2.0/24\nRequire IP 127.0.0.1\n#Require IP 192.168.108.133/24\nRequire IP 10.0.0.1/24;' "/etc/apache2/mods-available/status.conf"
diff -u "/etc/apache2/mods-available/status.conf.old" "/etc/apache2/mods-available/status.conf"
set +x
echo ""
read -p "Press Enter to continue, if the status.conf sed worked correctly"
echo ""

set -x
sudo cp -fv "/etc/apache2/mods-available/info.conf" "/etc/apache2/mods-available/info.conf.old"
sed -i 's;#Require IP 192.0.2.0/24;#Require IP 192.0.2.0/24\nRequire IP 127.0.0.1\n#Require IP 192.168.108.133/24\nRequire IP 10.0.0.1/24;' "/etc/apache2/mods-available/info.conf"
diff -u "/etc/apache2/mods-available/info.old" "/etc/apache2/mods-available/info."
set +x
echo ""
read -p "Press Enter to continue, if the info.conf sed worked correctly"
echo ""

# Leave port 80 listening, so do not comment-out the line which says Listen 80 in /etc/apache2/ports.conf

echo "# enable the apache default-tls site and disable the 000-default site"
set -x
#ls -al /etc/apache2/sites-available
ls -al /etc/apache2/sites-enabled
sudo a2ensite default-tls
sudo a2dissite 000-default
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

echo ""
echo "# Create the self-signed Certificate Files for use with TLS"
set -x
sudo mkdir -p /etc/tls/localcerts
set +x

echo ""
echo "# find local hostname eg Pi4CC"
set -x
hostname
hostname --fqdn
hostname --all-ip-addresses
set +x

echo ""
echo "# ASSUME THE HOSTNAME IS Pi4CC "
echo "#    IF NOT, exit this script and change it !!!!!"
echo "# Now Create the Certificate and Key (12650 = 50 years)"
echo "# REMEMBER any passwords !!!     Write them down !!!!"
set -x
sudo openssl req -x509 -nodes -days 12650 -newkey rsa:2048 -out /etc/tls/localcerts/Pi4CC.pem -keyout /etc/tls/localcerts/Pi4CC.key
set +x
echo ""
read -p "Press Enter to continue"
echo ""

echo "# Strip Out Passphrase from the Key"
set -x
cp /etc/tls/localcerts/Pi4CC.key /etc/tls/localcerts/Pi4CC.key.orig
openssl rsa -in /etc/tls/localcerts/Pi4CC.key.orig -out /etc/tls/localcerts/Pi4CC.key
sudo chmod 600 /etc/tls/localcerts/*
set +x
echo ""
read -p "Press Enter to continue"
echo ""

#Enter pass phrase for Pi4CC.key: Certificates
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
#Common Name (e.g. server FQDN or YOUR name) []:Pi4CC
#Email Address []:heckle@gmail.com
#
#Please enter the following 'extra' attributes
#to be sent with your certificate request
#A challenge password []:
#An optional company name []:

echo ""
echo "# In /etc/tls/localcerts we should now have"
echo "# Pi4CC.key.orig  cert key with embedded Passphrase"
echo "# Pi4CC.key       cert key"
echo "# Pi4CC.pem       final certificate"
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
sudo openssl pkcs12 -export -out /etc/tls/localcerts/Pi4CC.pfx -inkey /etc/tls/localcerts/Pi4CC.key.orig -in /etc/tls/localcerts/Pi4CC.pem 
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

#------------------------------------------------------------------------------------------------------------------------------

# Update Apache2 config
# Edit the tls conf and insert all of the good stuff
sudo nano /etc/apache2/sites-enabled/default-tls.conf
# Add stuff to make it look like the below :::::

<IfModule mod_gnutls.c> 
   #
   # from /etc/apache2/conf-available/security.conf
   # ServerTokens
   # This directive configures what you return as the Server HTTP response
   # Header. The default is 'Full' which sends information about the OS-Type
   # and compiled in modules.
   # Set to one of:  Full | OS | Minimal | Minor | Major | Prod
   # where Full conveys the most information, and Prod the least.
   ServerTokens Full
   #
   # from /etc/apache2/conf-available/security.conf
   # Optionally add a line containing the server version and virtual host
   # name to server-generated pages (internal error documents, FTP directory
   # listings, mod_status and mod_info output etc., but not CGI generated
   # documents or custom error documents).
   # Set to "EMail" to also include a mailto: link to the ServerAdmin.
   # Set to one of:  On | Off | EMail
   ServerSignature On
   #
<VirtualHost _default_:443>
   ServerName Pi4CC
   ServerAdmin noname@noname.com
   DocumentRoot /var/www/
   MaxRanges unlimited
   MaxRangeOverlaps unlimited
   MaxRangeReversals unlimited
   Header set Accept-Ranges bytes
   Header set Access-Control-Allow-Origin "*" 
   Header set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept" 
   CheckSpelling On
   CheckCaseOnly On
   # /etc/apache2/conf-available/security.conf
   # Disable access to the entire file system except for the directories that are explicitly allowed later.
   # This currently breaks the configurations that come with some web application Debian packages.
   #<Directory />
   #   AllowOverride None
   #   Require all denied
   #</Directory>
   <Directory />
      Options +Includes +Indexes +FollowSymLinks +MultiViews
      AddEncoding gzip gz
      AllowOverride None
      Require all denied
      MaxRanges unlimited
      MaxRangeOverlaps unlimited
      MaxRangeReversals unlimited
      Header set Accept-Ranges bytes
      Header set Access-Control-Allow-Origin "*" 
      Header set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept" 
   </Directory>
   <Directory /var/www/>
      Options +Includes +Indexes +FollowSymLinks +MultiViews
      AllowOverride None
      Require all granted
      MaxRanges unlimited
      MaxRangeOverlaps unlimited
      MaxRangeReversals unlimited
      Header set Accept-Ranges bytes
      Header set Access-Control-Allow-Origin "*" 
      Header set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept" 
   </Directory>
   Alias /mp4library /mnt/mp4library/mp4library
   <Directory /mnt/mp4library/mp4library>
      Options +Includes +Indexes +FollowSymLinks +MultiViews
      AllowOverride None
      Require all granted
      #<ifModule mod_headers.c>
      MaxRanges unlimited
      MaxRangeOverlaps unlimited
      MaxRangeReversals unlimited
      Header set Accept-Ranges bytes
      Header set Access-Control-Allow-Origin "*" 
      Header set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept" 
      #</ifModule>
      #AuthType Basic
      #AuthName "Password Required"
      #AuthUserFile /usr/local/etc/apache_passwd
      #Require user johndoe
   </Directory>
   ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
   <Directory "/usr/lib/cgi-bin">
      AllowOverride None
      Options +Includes +ExecCGI -MultiViews +SymLinksIfOwnerMatch
      #Order allow,deny
      #Allow from all
	  Require all granted
   </Directory>
   #
   # Possible values include: debug, info, notice, warn, error, crit, alert, emerg.
   LogLevel warn
   ErrorLog ${APACHE_LOG_DIR}/error.log
   CustomLog ${APACHE_LOG_DIR}/tls_access.log combined
   #
   # GnuTLS Switch: Enable/Disable SSL/TLS for this virtual host.
   # Use the certificate and key files we created earlier
   GnuTLSEnable On
   GnuTLSCertificateFile /etc/tls/localcerts/Pi4CC.pem
   GnuTLSKeyFile         /etc/tls/localcerts/Pi4CC.key
   # A self-signed (snakeoil) certificate can instead be created by installing the ssl-cert package. 
   # See /usr/share/doc/apache2.2-common/README.Debian.gz for more info.
   #GnuTLSCertificateFile   /etc/ssl/certs/ssl-cert-snakeoil.pem
   #GnuTLSKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
   #   See http://www.outoforder.cc/projects/apache/mod_gnutls/docs/#GnuTLSPriorities
   #
   GnuTLSPriorities NORMAL 
</VirtualHost> 
</IfModule>
#control O
#control X


# Edit the 000-default conf and insert all of the good stuff
sudo nano /etc/apache2/sites-enabled/000-default.conf
# and add stuff to make it look like the below :::::

   #
   # from /etc/apache2/conf-available/security.conf
   # ServerTokens
   # This directive configures what you return as the Server HTTP response
   # Header. The default is 'Full' which sends information about the OS-Type
   # and compiled in modules.
   # Set to one of:  Full | OS | Minimal | Minor | Major | Prod
   # where Full conveys the most information, and Prod the least.
   ServerTokens Full
   #
   # from /etc/apache2/conf-available/security.conf
   # Optionally add a line containing the server version and virtual host
   # name to server-generated pages (internal error documents, FTP directory
   # listings, mod_status and mod_info output etc., but not CGI generated
   # documents or custom error documents).
   # Set to "EMail" to also include a mailto: link to the ServerAdmin.
   # Set to one of:  On | Off | EMail
   ServerSignature On
   #
<VirtualHost _default_:80>
   ServerName Pi4CC
   ServerAdmin noname@noname.com
   DocumentRoot /var/www/
   MaxRanges unlimited
   MaxRangeOverlaps unlimited
   MaxRangeReversals unlimited
   Header set Accept-Ranges bytes
   Header set Access-Control-Allow-Origin "*" 
   Header set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept" 
   CheckSpelling On
   CheckCaseOnly On
   # /etc/apache2/conf-available/security.conf
   # Disable access to the entire file system except for the directories that are explicitly allowed later.
   # This currently breaks the configurations that come with some web application Debian packages.
   #<Directory />
   #   AllowOverride None
   #   Require all denied
   #</Directory>
   <Directory />
      Options +Includes +Indexes +FollowSymLinks +MultiViews
      AddEncoding gzip gz
      AllowOverride None
      Require all denied
      MaxRanges unlimited
      MaxRangeOverlaps unlimited
      MaxRangeReversals unlimited
      Header set Accept-Ranges bytes
      Header set Access-Control-Allow-Origin "*" 
      Header set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept" 
   </Directory>
   <Directory /var/www/>
      Options +Includes +Indexes +FollowSymLinks +MultiViews
      AllowOverride None
      Require all granted
      MaxRanges unlimited
      MaxRangeOverlaps unlimited
      MaxRangeReversals unlimited
      Header set Accept-Ranges bytes
      Header set Access-Control-Allow-Origin "*" 
      Header set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept" 
   </Directory>
   Alias /mp4library /mnt/mp4library/mp4library
   <Directory /mnt/mp4library/mp4library>
      Options +Includes +Indexes +FollowSymLinks +MultiViews
      AllowOverride None
      Require all granted
      #<ifModule mod_headers.c>
      MaxRanges unlimited
      MaxRangeOverlaps unlimited
      MaxRangeReversals unlimited
      Header set Accept-Ranges bytes
      Header set Access-Control-Allow-Origin "*" 
      Header set Access-Control-Allow-Headers "Allow-Origin, X-Requested-With, Content-Type, Accept" 
      #</ifModule>
      #AuthType Basic
      #AuthName "Password Required"
      #AuthUserFile /usr/local/etc/apache_passwd
      #Require user johndoe
   </Directory>
   ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
   <Directory "/usr/lib/cgi-bin">
      AllowOverride None
      Options +Includes +ExecCGI -MultiViews +SymLinksIfOwnerMatch
      #Order allow,deny
      #Allow from all
	  Require all granted
   </Directory>
   #
   # Possible values include: debug, info, notice, warn, error, crit, alert, emerg.
   LogLevel warn
   ErrorLog ${APACHE_LOG_DIR}/error.log
   CustomLog ${APACHE_LOG_DIR}/tls_access.log combined
</VirtualHost> 
#control O
#control X


# add an apache user, "pi"
sudo htpasswd -c /usr/local/etc/apache_passwd pi
# then enter your-intended-password twice

# At this point the folder /var/www/ still contains an index file something like index.html
# remove it so that we can do directory browsing from the root (it is handy)
sudo rm /var/www/Index.*
sudo rm /var/www/index.*

systemctl restart apache2
sudo service apache2 restart

journalctl -xe
cat /var/log/apache2/error.log

sudo nano /var/www/example.php
<?php echo "Today's date is ".date('Y-m-d H:i:s');
phpinfo();
?>
#control O
#control X

sudo nano /var/www/phpinfo.php
# Put these lines in the file.
<?php
phpinfo();
?>
#control O
#control X

# Remotely:
http://10.0.0.6/server-status
http://10.0.0.6/server-info
http://10.0.0.6/phpinfo.php
http://10.0.0.6/example.php

# Locally:
curl --head 127.0.0.1
curl -I 127.0.0.1
# Check for accept-ranges bytes etc
#Accept-Ranges: bytes
#Access-Control-Allow-Origin: *
#Access-Control-Allow-Headers: Allow-Origin, X-Requested-With, Content-Type, Accept


#curl 127.0.0.1/server-status
#curl 127.0.0.1/server-info
#curl 127.0.0.1/phpinfo.php
#curl 127.0.0.1/example.php

# ------------------------------------------------------------------------------------------------------------------------
# INSTALL miniDLNA
# ----------------

# not strictly necessary to install, however it makes the server more "rounded" and accessible

# https://unixblogger.com/dlna-server-raspberry-pi-linux/

# https://www.youtube.com/watch?v=Vry0NpFjn5w

# https://www.deviceplus.com/how-tos/setting-up-raspberry-pi-as-a-home-media-server/

sudo apt update -y 
sudo apt upgrade -y
sudo mkdir -p /mnt/mp4library/miniDLNA/log
sudo chmod -R +777 /mnt/mp4library/miniDLNA

# Remove your old miniDLNA version
sudo apt purge minidlna -y
sudo apt remove minidlna -y
sudo apt autoremove -y

# Do the install
sudo apt install -y minidlna

# Change config settings to look like these
sudo nano /etc/minidlna.conf
#user=minidlna
user=pi
#...
# Path to the directory you want scanned for media files.
# This option can be specified more than once if you want multiple directories
# scanned.
# If you want to restrict a media_dir to a specific content type, you can
# prepend the directory name with a letter representing the type (A, P or V),
# followed by a comma, as so:
# * "A" for audio (eg. media_dir=A,/var/lib/minidlna/music)
# * "P" for pictures (eg. media_dir=P,/var/lib/minidlna/pictures)
# * "V" for video (eg. media_dir=V,/var/lib/minidlna/videos)
# * "PV" for pictures and video (eg. media_dir=PV,[...]
media_dir=PV,/mnt/mp4library/mp4library
db_dir=/mnt/mp4library/miniDLNA
log_dir=/mnt/mp4library/miniDLNA/log
friendly_name=Pi4CC-miniDLNA
inotify=yes
strict_dlna=no
enable_tivo=no
notify_interval=300
max_connections=4
log_level=artwork,database,general,http,inotify,metadata,scanner,ssdp,tivo=info
#control O
#control X

sudo service minidlna restart
# after re-start, looks for media

# force a re-scan at 4:00 am every night
https://sourceforge.net/p/minidlna/discussion/879956/thread/41ae22d6/#4bf3
sudo /usr/bin/killall minidlna
sleep 10
sudo /usr/sbin/minidlna -R
sleep 3600
sudo /usr/bin/killall minidlna
sleep 10
sudo /usr/sbin/minidlna

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
sudo apt -y install samba samba-common-bin

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
comment=Pi4CC pi home
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

[mp4library]
comment=Pi4CC mp4library
#force group = users
#guest only = Yes
guest ok = Yes
public = yes
#valid users = @users
path = /mnt/mp4library
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
comment=Pi4CC www home
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
# "walk" the mp4library in our browser
# ------------------------------------
#
# Use a chrome browser to check if it is working.
# Navigate to the mp4library of the Pi web server 
# by typing the following into your web browser using your Pi's IP address
# http://10.0.0.6/mp4library
# and we should be able to navigate the mp4library folder tree
#
# To copy .mp4 files to/from the Pi via SAMBA (file shares) -
# From a Windows 7 PC, use Windows Explorer to open a share on 
# the Pi using its IP address, put it in the address bar of Windows Explorer
# \\10.0.0.6\
# and see a number of shares including
#    mp4library
#    www
# Open the mp4library share. See the files and folders there.
# We can copy files to/from it just like any other windows folders.

# ------------------------------------------------------------------------------------------------------------------------

# Setup the Pi4CC website for chromecasting
#
# setup ready for the pything script
sudo apt install -y mediainfo
pip3 install pymediainfo

# which contains a web page for local LAN access and control of casting, if not using a 3rd party app
# as well as the python3 app to regenerate 

# create the Pi4CC folder inside Apache2 folder
sudo mkdir /var/www/Pi4CC
sudo chown -R -f pi:www-data /var/www/Pi4CC
sudo chmod +777 -R /var/www/Pi4CC

# Copy the Pi4CC folder/file tree from github into this folder 
#   /var/www/Pi4CC
# (samba can be handy for that)

# RE-CREATE the essential JSON file used by the Pi4CC website
# Invoke this script manually from the commandline like
python3 /var/www/Pi4CC/2019.12.10-create-json.py --source_folder /mnt/mp4library/mp4library --filename-extension mp4 --json_file /var/www/Pi4CC/media.js > /var/www/Pi4CC/create-json.log 2>&1

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
@reboot python3 /var/www/Pi4CC/2019.12.10-create-json.py --source_folder /mnt/mp4library/mp4library ---filename-extension mp4 --json_file /var/www/Pi4CC/media.js > /var/www/Pi4CC/create-json.log 2>&1 &
0 4 * * * python3 /var/www/Pi4CC/2019.12.10-create-json.py --source_folder /mnt/mp4library/mp4library ---filename-extension mp4 --json_file /var/www/Pi4CC/media.js > /var/www/Pi4CC/create-json.log 2>&1

#View your currently saved scheduled tasks with:
crontab -l

# Visit the web page from a different PC to see if it all works:
https://10.0.0.6/Pi4CC
# You may need to accept that the self-signed security certificate is "insecure" (cough, it is, it's solely inside your LAN)
# and allow it (proceed to "unsafe" website anyway)
# If you like, in Chrome browser, "hamburger" -> More Tools -> Developer Tools an watch the instrumentation log fly along (don't).


# How to use the website site https://10.0.0.6/Pi4CC
# --------------------------------------------------
# Notes:
# 1. https: is "required" to cast videos to chromecast devices
# 2. All of the javascript runs on the client-side (i.e in the user browser)
# 3. The web page uses native HTML5 "<details> for drop-down lists
# 4. On a tablet or PC, open web page https://10.0.0.6/Pi4CC IN A CHROME BROWSER ONLY
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