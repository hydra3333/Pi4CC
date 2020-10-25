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

echo "# ------------------------------------------------------------------------------------------------------------------------"
cd ~/Desktop
. "./setup_1.4_install_configure_proftpd.sh"
set +x
echo "# ------------------------------------------------------------------------------------------------------------------------"
exit
