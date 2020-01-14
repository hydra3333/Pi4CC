REM #!/bin/bash
REM # to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
REM # or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
REM 
REM set -x
REM cp -fv /var/www/Pi4CC/media.js /var/www/Pi4CC/media.js.old 2>&1 >> /var/www/Pi4CC/create-json.log
REM python3 /var/www/Pi4CC/create-json.py --source_folder /mnt/mp4library/mp4library --filename-extension mp4 --json_file /var/www/Pi4CC/media.js 2>&1 >> /var/www/Pi4CC/create-json.log
REM #cat /var/www/Pi4CC/media.js 2>&1 >> /var/www/Pi4CC/create-json.log
REM #
REM exit
REM 
@echo on
G:
cd G:\000-Development\IIS\Pi4CC
python G:\000-Development\IIS\Pi4CC\create-json.py --source_folder T:\HDTV\autoTVS-mpg\Converted --filename-extension mp4 --json_file G:\000-Development\IIS\Pi4CC\media.js 2>&1 >> G:\000-Development\IIS\Pi4CC\create-json.log
REM pause
REM exit
