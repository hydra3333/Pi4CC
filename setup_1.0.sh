#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#

set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
# Ask for and setup default settings and try to remember them
. "./setup_0.1_ask_defaults.sh"
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

echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
## Install and Configure Apache2
cd ~/Desktop
. "./setup_1.1_install_configure_apache2.sh"
set +x
echo "# ------------------------------------------------------------------------------------------------------------------------"


echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
## Install and Configure miniDLNA
cd ~/Desktop
. "./setup_1.2_install_configure_miniDLNA.sh"
set +x
echo "# ------------------------------------------------------------------------------------------------------------------------"

echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
## Install and Configure SAMBA
cd ~/Desktop
. "./setup_1.3_install_configure_SAMBA.sh"
set +x
echo "# ------------------------------------------------------------------------------------------------------------------------"

echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
## Install and Configure vsftpd
#cd ~/Desktop
#. "./setup_1.4.1_install_configure_vsftpd.sh"
#set +x
## Install and Configure proftpd
cd ~/Desktop
. "./setup_1.4_install_configure_proftpd.sh"
set +x
echo "# ------------------------------------------------------------------------------------------------------------------------"

echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
## Install and Configure local Chromecast Pi4CC website
cd ~/Desktop
. "./setup_1.5_install_configure_local_Pi4CC_website.sh"
set +x
echo "# ------------------------------------------------------------------------------------------------------------------------"

echo "# ************************************************************************************************************************"
echo "# ************************************************************************************************************************"
echo "# ************************************************************************************************************************"
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

