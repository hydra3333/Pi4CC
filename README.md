# UNDER CONSTRUCTION

does not work yet

# Description <TL;DR> 

   A zero-frills LAN-only Media Server using DLNA and Apache2 web server to serve up .mp4 (avc/hevc) video files
   from a low-cost low-power Raspberry Pi 4 server to Chromecast devices and SmartTVs in the home.
   
   Once installed and configured, the Pi 4 will eventally run "headless" (i.e. without a monitor/keyboard/mouse);
   if required, it can be accessed and controlled remeotely from a PC via VNC or SSH etc.

# More Description:

How to setup a Raspberry Pi 4 4Gb (Raspbian buster) as a HOME LAN media server (only inside a home LAN) so that :-
1. via DLNA, it can be searchable and serve .mp4 files to Apps on tablets and phones and smartTVs
2. via a LAN-only web page, it can it can be searchable on tablets and phones and PCs, 
   and be able to "cast" .mp4 files to Chromecast devices connected to TVs 
   (eg a Chromecast Ultra, which can play h.265).
Hence,
3. Remember, "casting" a .mp4 files means that once a .mp4 file is cast to a Chromecast device, 
   serving up the data in the large .mp4 video file is then directly between the 
   chromecast device and the Pi 4 (i.e. a tablet or phone or PC does not forward data packets)
   and the casting phone/tablet/PC (known as a Sender) then only chats with the chromecast device
   to control video playback.
4. After setup, the monitor/mouse/keyboard can be disconnected from the Pi4. 
5. It does NOT do any "non-Google-app" *external* network connections outside your home LAN at runtime
      ... unlike Plex Media Server (search about it in the Raspberry Pi forums)
      ... unlike Kodi 
   ... Your list of media contents etc is NOT shared with any company or individual. 
   You are in control.
6. If you want something better and fancier, 
   look for Plex Media Server and Kodi. They're good, if you are willing to be a "sharing" individual ;)
5. This is based solely on the Google "CastVideos-chrome" example at 
      https://github.com/googlecast/CastVideos-chrome
   with "minimal" changes.

Key things installed and configured:
1. A Raspberry Pi 4 server with hostname Pi4CC (or whatever name you specify) with relevant software and settings
2. A USB3 (10Tb ?) external drive with a fixed mount point etc
3. A miniDLNA server
4. A SAMBA file-sharing software compatible with Windows file shares
5. An Apache2 web server, with a self-signed SSL/TLS cerfificate
6. A local Pi4CC website (and bits) and companion python3 script and relevant crontab entries to re-index nightly

# Installation

1. Prepare an external USB3 hard drive (formatted as NTFS is good)
   - In Windows, ensure
     - "security" on the drive itself is set to `everyone` having `full control`
     - a top-level folder is created called `mp4library`, with "security" on this folder set to `everyone` having `full control`
     - copy your playable .mp4 files into that level and/or subfolders
     - Of probable interest, playable .mp4 files are 
         * not interlaced (a `Chromecast` device will not play them)
         * max resolution of `1080p` and `SDR` colours (unless you have a `Chromecast Ultra` device, in which case `4K` and `HDR`)
         * ideally encoded with codecs `h.264(avc)/aac` or `h.265(hevc)/aac`
         * google's probably out-of-date list of acceptable .mp4 codecs is at https://developers.google.com/cast/docs/media
   - Note: 
     - In the Pi, we will set the mount point for the USB3 disk to (usually) be `/mnt/mp4library`
     - The top level folder on the USB3 disk will (usually) be `mp4library`, thus accessible in the Pi via `/mnt/mp4library/mp4library`

3. Install and configure your Raspberry Pi 4 4Gb and set it to always to boot to GIU and autologin
   - it is close enough to safe to autologin since the Pi is only visible inside your "secure" home LAN
   - (the GUI should be left to boot and run, even in a headless state later)
4. Check, perhaps in the GUI menu item `Raspberry Pi Configuration`,
   -  its hostname is short and easy and has no spaces or special characters (it will be used as the website name)
   - "login as user pi" is ticked
   - "wait for network" is ticked
   - "splash screen" is disabled
   -  VNC is enabled
   -  SSH is enabled
   - GPU memory is 384k
   - "localisation" tab is used to check/configure your timezone/locale etc
5. Also check the Pi has a fixed IP address, perhaps by setting your home router's DHCP facility to recognise the Pi's mac address and provide a fixed IP address
6. Clone the respository to the Desktop of the Pi and copy the setup files to the Desktop
   - start a Terminal and do this:
     ```
     cd ~/Desktop
     sudo apt install -y git
     git clone https://github.com/hydra3333/Pi4CC.git
     cp -fv ./Pi4CC/setup_0.sh ./
     cp -fv ./Pi4CC/setup_1.sh ./
     chmod +777 *.sh
     ```
   - you are greatly encouraged to view and check files `setup_0.sh` and `setup_1.sh` to see they do nothing nefarious :)
7. Do part "Setup 0" of the installation (it should be re-startable, feel free to "Control C" and re-start if you feel uncomfortable)
   - plug the USB3 external hard drive in to the Pi (always use the same USB3 slot in the Pi)
   - wait 15 seconds for the USB3 external hard drive to spin up and be recognised automatically
   - find and note EXACTLY the correct `UUID=` string of letters and numbers for the USB3 external hard drive ; start a Terminal and do this:
     ```
     sudo df
     sudo blkid 
     ```
     * which should yield something like this
       ```
       /dev/mmcblk0p1: LABEL_FATBOOT="boot" LABEL="boot" UUID="69D5-9B27" TYPE="vfat" PARTUUID="d9b3f436-01"
       /dev/mmcblk0p2: LABEL="rootfs" UUID="24eaa08b-10f2-49e0-8283-359f7eb1a0b6" TYPE="ext4" PARTUUID="d9b3f436-02"
       /dev/sda2: LABEL="5TB-mp4library" UUID="F8ACDEBBACDE741A" TYPE="ntfs" PTTYPE="atari" PARTLABEL="Basic data partition" PARTUUID="6cc8d3fb-6942-4b4b-a7b1-c31d864accef"
       /dev/mmcblk0: PTUUID="d9b3f436" PTTYPE="dos"
       /dev/sda1: PARTLABEL="Microsoft reserved partition" PARTUUID="62ac9e1a-a82b-4df7-92b9-19ffc689d80b"
       ```
     * in thise case (and not yours) it is self-evidently `F8ACDEBBACDE741A` ... copy and paste it somewhere you can copy it from later
   - Now, in a Terminal and do this:
     ```
     cd ~/Desktop
     chmod +777 *.sh
     ./setup_0.sh
     ```
   - answer initial prompts (it will save these answers for use later)
     * `This server_name` it's best to enter the hostname of the Pi here (I use Pi4CC), it will be used as the Apache2 website name
     * `This server_alias (will become a Virtual Folder within the website)` recommend leave it as `mp4library` 
	 ... it will be used as the top-level folder name on your external USB3 hard drive, so put your media files there
     * `Designate the mount point for the USB3 external hard drive` it's a "virtual" place used everywhere to access the top level of the USB3 external hard drive when mounted, eg `/mnt/mp4library`
     * `Designate the root folder on the USB3 external hard drive` it's the top level folder on the USB3 external hard drive containing .mp4 files and subfolders containing .mp4 files, eg `/mnt/mp4library/mp4library`
   - answer other prompts
     * sometimes you will be asked to visually scan setup results for issues, and press Enter to continue
     * when you see this
       ```
       + sudo cp -fv /etc/fstab /etc/fstab.old
       '/etc/fstab' -> '/etc/fstab.old'
       + sudo sed -i '$ a #UUID=F8ACDEBBACDE741A /home/pi/Desktop/zzz ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=1000,gid=1000,noatime,x-systemd.device-timeout=120 0 2' /etc/fstab
       + set +x
       Press Enter to start nano to uncomment the line and CHANGE to the correct UUID  
       ```
       you are about to start the `nano` editor to do 2 things:
	     * remove the `#` at the start of the line containing `UUID=F8ACDEBBACDE741A`
	     * remove the `F8ACDEBBACDE741A` string and enter the UUID string you saved earlier ... good luck
   - Reboot the Pi so that any new settings take effect
8. After rebooting, do part "Setup 1" of the installation (it should be re-startable, feel free to "Control C" and re-start if you feel uncomfortable)
   - this will be a longish process (15 to 30 mins) with a number of prompts
   - answer initial prompts (it will remember the answers you gave in setup_0 as defaults ... don't change them now !)
   - answer other prompts
     * sometimes you will be asked to visually scan setup results for issues, and press Enter to continue
     * observe progress and "control C" if you spot anything "unfortunate" occurring







# Test it out on a PC first ?

Perhaps consider using Raspberry PI Desktop in a VMware Player virtual machine on a PC ?

https://www.raspberrypi.org/forums/viewtopic.php?f=116&t=200252&p=1588362#p1586023

You may have "fun" trying to finding  its IP address for remote https connections into it, have a try or
preferably use the chromium browser inside the Raspberry PI Desktop vm.



# How to encode .mp4 content which is playable ?

Perhaps place some ffmpeg example commandlines in here.


# Addendum:

Documentation
* [Google Cast Chrome Sender Overview](https://developers.google.com/cast/docs/chrome_sender/)
* [Developer Guides](https://developers.google.com/cast/docs/developers)

References
* [Chrome Sender Reference](http://developers.google.com/cast/docs/reference/chrome)
* [Design Checklist](http://developers.google.com/cast/docs/design_checklist)

How to report bugs
* [Google Cast SDK Support](https://developers.google.com/cast/support)
* For sample app issues, open an issue on this GitHub repo.

Terms
Your use of this sample is subject to, and by using or downloading the sample files you agree to comply with, the [Google APIs Terms of Service](https://developers.google.com/terms/) and the [Google Cast SDK Additional Developer Terms of Service](https://developers.google.com/cast/docs/terms/).


TAKE 2:
