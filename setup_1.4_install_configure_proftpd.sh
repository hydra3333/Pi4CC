#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# Build and configure HD-IDLE
# Call this .sh like:
# . "./setup_1.4_install_configure_proftpd.sh"
#
set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# INSTALL proftpd ftp server, connectable from filezilla"
echo "# (proftpd is more common than VSFTPD, so VSFTPD has been superseded here; it still works though)"
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo ""
set -x
sudo kill -TERM `cat /run/proftpd.pid`
sudo rm -fv "/etc/shutmsg"
sudo apt purge -y proftpd proftpd-basic proftpd-mod-case proftpd-doc 
sudo chmod -c a=rwx -R "/etc/proftpd/proftpd.conf"
sudo rm -vf "/etc/proftpd/proftpd.conf" "/etc/proftpd/proftpd.conf.old"
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
sudo kill -TERM `cat /run/proftpd.pid`
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
sudo sed -i "s;Group\t\t\t\tpi;Group\t\t\t\tpi\nDefaultRoot \~ \!pi,\!www-data;g" "./tmp.tmp"
sudo sed -i "s;Umask\t\t\t\t022  022;Umask\t\t\t\t000  000;g" "./tmp.tmp"
#"/boot_delay/d"
sudo sed -i '/# Include other custom configuration files/d' "./tmp.tmp"
sudo sed -i '/Include \/etc\/proftpd\/conf.d\//d' "./tmp.tmp"
#cat<<EOF >>"./tmp.tmp"
#<Anonymous ~pi>
#User pi
#Group pi
#DefaultRoot ~ !pi,!www-data
#UserAlias anonymous pi
#RequireValidShell off
#MaxClients 30
#Umask 000 000
#<Directory *>
#Umask 000 000
#<Limit WRITE>
#AllowAll
#</Limit>
#</Directory>
#</Anonymous>
# Include other custom configuration files
#Include /etc/proftpd/conf.d/
#EOF
#cat "./tmp.tmp"
#
sudo cp -fv "./tmp.tmp" "/etc/proftpd/proftpd.conf"
rm -f "./tmp.tmp"
ls -al "/etc/proftpd/proftpd.conf.old" "/etc/proftpd/proftpd.conf"
diff -U 1 "/etc/proftpd/proftpd.conf.old" "/etc/proftpd/proftpd.conf"
# re-enable server
sudo kill -TERM `cat /run/proftpd.pid`
sudo rm -fv "/etc/shutmsg"
sudo proftpd
#
sudo proftpd -t -d5
#sudo proftpd -vv
#sudo proftpd --list 
set +x
##read -p "Press Enter to continue, if that all worked"
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
