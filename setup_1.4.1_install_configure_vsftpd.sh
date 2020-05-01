#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# Build and configure HD-IDLE
# Call this .sh like:
# . "./setup_1.4_install_configure_vsftpd_superseded.sh"
#
set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
echo "# -----------------------------------------------------"
echo "# VSFTPD has been superseded - replaced by proftpd"
echo "# VSFTPD has been superseded - replaced by proftpd"
echo "# VSFTPD has been superseded - replaced by proftpd"
echo "# VSFTPD has been superseded - replaced by proftpd"
echo "# VSFTPD has been superseded - replaced by proftpd"
echo "# VSFTPD has been superseded - replaced by proftpd"
echo "# VSFTPD has been superseded - replaced by proftpd"
echo "# VSFTPD has been superseded - replaced by proftpd"
echo "# VSFTPD has been superseded - replaced by proftpd"
echo "# VSFTPD has been superseded - replaced by proftpd"
echo "# -----------------------------------------------------"

echo "# -----------------------------------------------------"
echo "# INSTALL VSFTPD ftp server, connectable from filezilla"
echo "# -----------------------------------------------------"
echo ""

set -x 
sudo service vsftpd stop
sudo apt-get purge -y vsftpd
sudo chmod -c a=rwx -R "/etc/vsftpd.conf"
sudo rm -vf "/etc/vsftpd.conf"
sudo apt-get install -y vsftpd
set +x
#
# https://security.appspot.com/vsftpd/vsftpd_conf.html
# http://vsftpd.beasts.org/vsftpd_conf.html
# Remember
# local_umask ( 0011 ) is subtracted. 
# The umask essentially removes the permissions you don't want users to have, so use 000

set -x
# https://security.appspot.com/vsftpd/vsftpd_conf.html
sudo service vsftpd stop
sudo chmod -c a=rwx -R "/etc/vsftpd.conf"
sudo cp -fv "/etc/vsftpd.conf" "/etc/vsftpd.conf.backup"
sudo sed -i "s;listen=NO;listen=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;listen_ipv6=YES;listen_ipv6=NO;g" "/etc/vsftpd.conf"
sudo sed -i "s;anonymous_enable=NO;anonymous_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;local_enable=YES;write_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#local_umask=022;local_umask=000;g" "/etc/vsftpd.conf"
sudo sed -i "s;#anon_upload_enable=YES;anon_upload_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#anon_mkdir_write_enable=YES;anon_mkdir_write_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;use_localtime=YES;use_localtime=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;xferlog_enable=YES;xferlog_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#chown_uploads=YES;chown_uploads=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#chown_username=whoever;chown_username=pi;g" "/etc/vsftpd.conf"
sudo sed -i "s;#xferlog_std_format=YES;xferlog_std_format=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#idle_session_timeout=600;idle_session_timeout=1200;g" "/etc/vsftpd.conf"
sudo sed -i "s;#ftpd_banner=Welcome to blah FTP service.;ftpd_banner=${server_name} ftp service;g" "/etc/vsftpd.conf"
sudo sed -i "s;#chroot_local_user=YES;chroot_local_user=NO;g" "/etc/vsftpd.conf"
sudo sed -i "s;#ls_recurse_enable=YES;ls_recurse_enable=YES;g" "/etc/vsftpd.conf"
sudo sed -i "s;#xferlog_file=/var/log/vsftpd.log;xferlog_file=/var/log/vsftpd.log;g" "/etc/vsftpd.conf"
sudo sed -i "s;#utf8_filesystem=YES;utf8_filesystem=YES;g" "/etc/vsftpd.conf"
sudo echo "#" >> "/etc/vsftpd.conf"
sudo echo "## add our extra stuff" >> "/etc/vsftpd.conf"
sudo echo "anon_root=/home" >> "/etc/vsftpd.conf"
sudo echo "local_enable=YES" >> "/etc/vsftpd.conf"
sudo echo "allow_anon_ssl=YES" >> "/etc/vsftpd.conf"
sudo echo "anon_other_write_enable=YES" >> "/etc/vsftpd.conf"
sudo echo "delete_failed_uploads=YES" >> "/etc/vsftpd.conf"
sudo echo "dirlist_enable=YES" >> "/etc/vsftpd.conf"
sudo echo "download_enable=YES" >> "/etc/vsftpd.conf"
sudo echo "no_anon_password=YES" >> "/etc/vsftpd.conf"
sudo echo "force_dot_files=YES" >> "/etc/vsftpd.conf"
sudo echo "file_open_mode=0777" >> "/etc/vsftpd.conf"
sudo echo "ftp_username=pi" >> "/etc/vsftpd.conf"
sudo echo "guest_username=pi" >> "/etc/vsftpd.conf"
sudo echo "dual_log_enable=YES" >> "/etc/vsftpd.conf"
sudo echo "syslog_enable=NO" >> "/etc/vsftpd.conf"
sudo echo "vsftpd_log_file=/var/log/vsftpd.log" >> "/etc/vsftpd.conf"
sudo echo "log_ftp_protocol=YES" >> "/etc/vsftpd.conf"
sudo echo "allow_writeable_chroot=YES" >> "/etc/vsftpd.conf"
sudo diff -U 1 "/etc/vsftpd.conf.backup" "/etc/vsftpd.conf"
sudo service vsftpd restart
sleep 5s
sudo systemctl status vsftpd.service
sudo tail /var/log/syslog 
sudo tail /var/log/vsftpd.log
set +x
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
