#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save

set -x

sudo chown -R pi:www-data /var/www-old
sudo chown -R pi:www-data /var/www-new
sudo chown -R pi:www-data /var/www
sudo chmod a=rwx -R /var/www-old
sudo chmod a=rwx -R /var/www-new
sudo chmod a=rwx -R /var/www

cp -fvR /var/www/* /var/www-old/

sudo chown -R pi:www-data /var/www-old
sudo chown -R pi:www-data /var/www-new
sudo chown -R pi:www-data /var/www
sudo chmod a=rwx -R /var/www-old
sudo chmod a=rwx -R /var/www-new
sudo chmod a=rwx -R /var/www

#sleep 3s
#systemctl restart apache2
sudo service apache2 restart
sleep 10s

exit
