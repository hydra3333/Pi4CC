#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save

set -x

python3 /var/www/Pi4CC/create-json.py --source_folder /mnt/mp4library/mp4library --filename-extension mp4 --json_file /var/www/Pi4CC/media.js 2>&1 > /var/www/Pi4CC/create-json.log
#
cat /var/www/Pi4CC/create-json.log
#
cat /var/www/Pi4CC/media.js
#
exit
