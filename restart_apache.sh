#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save

echo "Restart the Apache2 Service"
set -x
#sleep 3s
#systemctl restart apache2
sudo service apache2 restart
sleep 10s
set +x