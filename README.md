# UNDER CONSTRUCTION

It works ... and is undergoing "refinement".

---

# Description <TL;DR> 

   A zero-frills LAN-only Media Server using DLNA and Apache2 web server to serve up .mp4 (avc/hevc) video files
   from a low-cost low-power Raspberry Pi 4 server to Chromecast devices and SmartTVs in the home.  No transcoding is done.
   
   Once installed and configured, the Pi 4 will run "headless" (i.e. without a monitor/keyboard/mouse);
   if required, it can be accessed and controlled remotely from a Windows PC via VNC or SSH etc.
   
---

   It can (and has been) run under Windows 10 using Win10 native IIS as the web server and a self-signed SSL certificate,
   with manually-configured IIS (it is easy) and a few Pi4CC files manually edited.  No automated install script though. 
   Windows 10 installation notes are near the bottom of this page.

---

# Description:

**Key things installed and configured:**
  1. A USB3 (10Tb ?) external hard drive with a fixed mount point, containing your .mp4 video files   
      1. if you have 2x USB3 disks with media, you may need to create a Symlink (soft) under mp4library on the "main" disk to an existing subfolder on the "secondary" disk - so that when browsing the main disk the subfolder on the secondary disk looks like a subfolder on the main disk, using   
	  ```
	  ln -s <path_to_existing_foldername_on_secondary_disk> <path_to_symlink_to_be_created>   
	  sudo chmod +777 <path_to_symlink_to_be_created>
	  ```
      2. eg   
	  ```
	  ln -s /dev/sdb1/mp4library/Series /mnt/mp4library/mp4library/Series   
	  sudo chmod +777 /mnt/mp4library/mp4library/Series
	  ```
	  creates Symlink `/mnt/mp4library/mp4library/Series` to folder `/dev/sdb1/mp4library/Series`.   
      3. remember, first make sure the Symlink "filename" does NOT already exist !   
      4. to remove an existing Symlink, first use   
	  ```
	  ls -l /mnt/mp4library/mp4library/Series
	  ```   
	  to check it is actually a Symlink with property "L" ... and then use   
	  ```
	  unlink /mnt/mp4library/mp4library/Series
	  ```
	  to remove the Symlink
  2. A miniDLNA server, so you can find and play .mp4 files from a remote tablet or phone or smartTV etc
  3. A SAMBA file-sharing software compatible with Windows file shares, so you can easily copy files back and forth (slowly)
  4. An Apache2 web server, with a self-signed SSL/TLS cerfificate, so you can access .mp4 files via a browser
  5. A local "Pi4CC" website (and bits) in Apache, with a companion python3 script and relevant crontab entries to re-index
     your videos nightly, so you can find and "cast" .mp4 files to Chromecast devices


**Setup a Raspberry Pi 4 4Gb (Raspbian buster) as a HOME LAN media server (only inside a home LAN) so that** :-
  1. via DLNA, it can be searchable and serve .mp4 files to Apps on tablets and phones and smartTVs etc
  2. via a LAN-only web page, it can it can be searchable on tablets and phones and PCs, 
     and be able to "cast" .mp4 files to Chromecast devices connected to TVs 
     (eg a Chromecast Ultra, which can play h.265). <br />
**Hence,**
  3. Remember, "casting" a .mp4 files means that once a .mp4 file is cast to a Chromecast device, 
     serving up the data in the large .mp4 video file is then directly between the 
     chromecast device and the Pi 4 (i.e. a tablet or phone or PC does not forward data packets)
     and the casting phone/tablet/PC (known as a Sender) then only chats with the chromecast device
     to control video playback.
  4. After setup, the monitor/mouse/keyboard can be disconnected from the Pi4. 
  5. It does NOT do any "non-Google-app" *external* network connections outside your home LAN at runtime
        ... unlike Plex Media Server (search about it in the Raspberry Pi forums)
        ... unlike Kodi 
     ... Your list of video contents etc is NOT shared with any company or individual. 
     You are in control.
  6. If you want something better and fancier, 
     look for Plex Media Server and Kodi. They're good, if you are willing to be a "sharing" individual ;)
  5. This is based solely on the Google "CastVideos-chrome" example at 
        https://github.com/googlecast/CastVideos-chrome
     with "minimal" changes.

---

## LINUX Installation (eg under Raspbian)

1. Prepare an external USB3 hard drive (formatted as NTFS is good)
   - In Windows, ensure
     - "security" on the drive itself is set to `everyone` having `full control`
     - a top-level folder is created called `mp4library`, with "security" on this folder set to `everyone` having `full control`
     - copy your playable .mp4 files into that level and/or subfolders
     - Of probable interest, playable .mp4 files are 
         * not interlaced (a `Chromecast` device will not play them)
         * max resolution of `1080p` and having an `SDR` colour scheme (unless you have a `Chromecast Ultra` device, in which case `4K` and `HDR`)
         * ideally encoded with codecs `h.264(avc)/aac` ... or `h.265(hevc)/aac`
           * videos encoded with `hevc/avc` won't play in a Chrome browser, but they *will* cast to and play on a Chromecast device 
           * (... neither type of video plays inside a Pi's Chromium browser, unfortunately) 
         * google's *probably out-of-date list* of acceptable .mp4 codecs is at https://developers.google.com/cast/docs/media
   - Note: 
     - In the Pi, we will set the mount point for the USB3 disk to (usually) be `/mnt/mp4library`
     - The top level folder on the USB3 disk will (usually) be `mp4library`, thus accessible in the Pi via `/mnt/mp4library/mp4library`
2. Install and configure your Raspberry Pi 4 4Gb and set it to boot to GIU and autologin
   - it is close enough and safe to autologin since the Pi is only visible inside your "secure" home LAN
   - in a Terminal, using sudo raspi-config, Advanced,
     choose a screen resolution ANYTHING (eg 1920x1080) OTHER than "default" so that a framebuffer gets allocated on a Pi4
	 which magically enables VNC server to run even when a screen is not connected to the HDMI port
   - (the GUI should be left to boot and run, even in a headless state later)
3. Check, perhaps in the GUI menu item `Raspberry Pi Configuration`,
   -  its hostname is short and easy and has no spaces or special characters (it will be used as the website name)
   - "login as user pi" is ticked
   - "wait for network" is ticked
   - "splash screen" is disabled
   - VNC is enabled
   - SSH is enabled
   - GPU memory is 384k
   - "localisation" tab is used to check/configure your timezone/locale etc and set local language to UTF-8
4. Also check the Pi has a fixed IP address, perhaps by setting your home router's DHCP facility to recognise the Pi's mac address and provide a fixed IP address
   - Remember - if you are Wired ethernet: to disable WiFi on the Pi4, add this line into '/boot/config.txt' and reboot   
     `dtoverlay=pi3-disable-wifi`   
5. Clone the respository to the Desktop of the Pi and copy the setup files to the Desktop
   - start a Terminal and do this:
     ```
     cd ~/Desktop
     sudo apt install -y git
     git clone https://github.com/hydra3333/Pi4CC.git
     cp -fv ./Pi4CC/setup*.sh ./
     chmod +777 *.sh
     ```
   - you are greatly encouraged to view and check files `setup_0.0.sh` and `setup_1.0.sh` to see they do nothing nefarious :)
6. Do part "Setup 0" of the installation (it should be re-startable, feel free to "Control C" and re-start if you feel uncomfortable)
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
     * in thise case (and not yours) it is self-evidently `F8ACDEBBACDE741A` ... copy and paste it somewhere so you can use it later if required
   - Now, in a Terminal and do this:
     ```
     cd ~/Desktop
     chmod +777 *.sh
     ./setup_0.0.sh
     ```
   - answer initial prompts (it will save these answers for use later)
     * `This server_name` it's best to enter the hostname of the Pi here (I use Pi4CC), it will be used as the Apache2 website name
     * `This server_alias (will become a Virtual Folder within the website)` recommend leave it as `mp4library` 
	 ... it will be used as the top-level folder name on your external USB3 hard drive, so put your video files there
     * `Designate the mount point for the USB3 external hard drive` it's a "virtual" place used everywhere to access the top level of the USB3 external hard drive when mounted, eg `/mnt/mp4library`
     * `Designate the root folder on the USB3 external hard drive` it's the top level folder on the USB3 external hard drive containing .mp4 files and subfolders containing .mp4 files, eg `/mnt/mp4library/mp4library`
   - answer other prompts
     * sometimes you will be asked to visually scan setup results for issues, and press Enter to continue
   - Reboot the Pi so that any new settings take effect
7. After rebooting, do part "Setup 1" of the installation (it should be re-startable, feel free to "Control C" and re-start if you feel uncomfortable)
   - In a Terminal and do this:
     ```
     cd ~/Desktop
     chmod +777 *.sh
     ./setup_1.0.sh
     ```
   - this will be a longish process (15 to 30 mins) with a number of prompts
   - answer initial prompts (it will remember the answers you gave in `setup_0.0.sh` as defaults ... don't change them now !)
   - answer other prompts
     * sometimes you will be asked to visually scan setup results for issues, and press Enter to continue
     * observe progress and USE "control C" if you spot anything "unfortunate" occurring
     * when you see something like this (I cannot seem to avoid it prompting)
       ```
       + sudo openssl pkcs12 -export -out /etc/tls/localcerts/PiDesktop.pfx -inkey /etc/tls/localcerts/PiDesktop.key.orig -in /etc/tls/localcerts/PiDesktop.pem
       Enter Export Password:
       ```
       just press Enter, then press Enter again to the next prompt `Verifying - Enter Export Password:`
     * when you see something like this,
       ```
       # apache user, 'pi' ... Enter your normal password, then again
       + sudo htpasswd -c /usr/local/etc/apache_passwd pi
       New password: 
       ```
       enter the password you had set for the pi login, then enter it again when you see `Re-type new password:`
     * when you see something like this,
       ```
       Before we start the server, you’ll want to set a Samba password. Enter you pi password.
       + sudo smbpasswd -a pi
       New SMB password:
       ```
       enter the password you had set for the pi login, then enter it again when you see `Retype new SMB password:`
     * then when you see something like this,
       ```
       Before we start the server, you’ll want to set a Samba password. Enter you pi password.
       + sudo smbpasswd -a root
       New SMB password:
       ```
       enter the password you had set for the pi login, then enter it again when you see `Retype new SMB password:`
8. After rebooting now, it's ready.
   - try to connect to it from a PC or tablet using a Chrome browser,
     (where Pi4CC below is the hostname of the Pi and xx.xx.xx.xx is the fixed IP address of the Pi)
     ```
     https://xx.xx.xx.xx/Pi4CC
     https://xx.xx.xx.xx/mp4library
     ```
     on the Pi itself, you can try the Chromium browser to at least see if it works
     (where Pi4CC below is the hostname of the Pi and xx.xx.xx.xx is the fixed IP address of the Pi)
     ```
     https://xx.xx.xx.xx/Pi4CC
     https://xx.xx.xx.xx/mp4library
     ```
     * **Please note:** 
       * you won't be able to play a video in the Pi browser itself, but you can click on the `triangle` expander to see if it works
       * videos encoded with `hevc/avc` won't play in a Chrome browser, likely something to do with google and licensing of `hevc`
       * only a google Chrome browser on a PC or tablet works to cast videos from the website to a Chromecast device
   - you **WILL** see a Chrome message `Your connection is not private ... etc etc` which is due to 
     us using your (free) self-signed SSL/TLS certificate rather than a paid-for one (which has other associated complexities)
     * to accept this, click on the button `Advanced`
     * then click on the link which says `Proceed to xx.xx.xx.xx (unsafe)` (it be showing the hostname of the Pi)
     * the browser should remember this is OK, and proceed to display the Pi's new website
   - you can now disconnect the Pi from the monitor, keyboard, and mouse, if you want to make it headless   
     - yes, the GUI should be left running and left to start at boot time, so you can VNC into it later from your PC



# Test it out on a PC first ?

Perhaps consider using Raspberry PI Desktop in a VMware Player virtual machine on a PC ?

https://www.raspberrypi.org/forums/viewtopic.php?f=116&t=200252&p=1588362#p1586023

Use `ifconfig` in the Pi Desktop VM to find its IP address, which you can use to connect to it in a Chrome browser, eg
```
https://xxx.xxx.xxx.xxx/Pi4CC
https://xxx.xxx.xxx.xxx/mp4library
```
You can click on the `triangle` expander to see if it works.


# How to encode .mp4 content which is "cast" to be playable on a Chromecast ?


1. If you have a PC with a modern (eg RTX 2060 Super) video card, then to use NVIDIA's NVENC hardware transcoding :
   1. to `h.264/AAC` (`opencl=ocl:0.0` is the relevant video card ID) ... DEINTERLACE(TFF), small openCL-filter-sharpening for a slightly blurry source, encode using hardware "nvenc"
      ```
      "ffmpeg.exe" -v verbose -nostats -init_hw_device opencl=ocl:0.0 -filter_hw_device ocl -i "input_file.mpg" -map_metadata -1 -vsync 0 -sws_flags lanczos+accurate_rnd+full_chroma_int+full_chroma_inp
          -filter_complex "[0:v]yadif=0:0:0,hwupload,unsharp_opencl=lx=3:ly=3:la=0.5:cx=3:cy=3:ca=0.5,hwdownload,format=pix_fmts=yuv420p" -strict experimental
          -c:v h264_nvenc -pix_fmt nv12 -preset slow -bf 2 -g 50 -refs 3 -rc:v vbr_hq -rc-lookahead:v 32 -cq 22 -qmin 16 -qmax 25 -coder 1 -movflags +faststart+write_colr -profile:v high -level 5.1 
          -c:a libfdk_aac -cutoff 18000 -ab 384k -ar 48000 -y "output_file.h264.mp4"
      ```
   2. to `HEVC/AAC` ... `HEVC (h.265)` is only playable on a Chromecast Ultra ... DEINTERLACE(TFF), encode using hardware "nvenc"
      ```
      "ffmpeg.exe" -v verbose -nostats -i "input_file.mpg" -map_metadata -1 -vsync 0 -sws_flags lanczos+accurate_rnd+full_chroma_int+full_chroma_inp 
         -filter_complex "[0:v]yadif=0:0:0,format=pix_fmts=yuv420p" -strict experimental 
         -c:v hevc_nvenc -pix_fmt nv12 -preset slow -rc:v vbr_hq -2pass 1 -rc-lookahead:v 32 -cq 16 -qmin 14 -qmax 32 -spatial_aq 1 -temporal_aq 1 -profile:v main -level 5.1 -movflags +faststart+write_colr 
         -c:a libfdk_aac -cutoff 18000 -ab 384k -ar 48000 -y "output_file.hevc.mp4" 
      ```
2. If you have a PC without a modern video card, then perhaps use ffmpeg's `libx264` software transcoding ... similar to above, one day I may post an example.

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


---

# Windows 10 Installation

## Assumptions:

1. we're installing this into the default website
2. we're installing the `mp4library` `virtual directory` into the default website
3. we'll use a `self-signed SSL certificate` (since the `cast` icon only works if the web page is https)
4. we'll enable use of use `https` and `http`, using both the server name and (mandatorily) the fixed IP address
5. we'll use the fixed IP address in a browser to access the web page and it's components (only this has been tested to work)
6. we've pre-created a disk/folder full of subdirectories and `.mp4` files
7. we have at least `Python 3.8.1` installed (installer `Run as Administrator`, `Advanced` options `for all users` and all related options set)

## How to for Windows 10:

### Preliminary software requirements

Download and install `Python 3.8.1` or later (installer `Run as Administrator`, `Advanced` options `for all users` and all related options set)  
Source: `https://www.python.org/downloads/`  and use the `Windows x86-64 executable installer`.  

Once Python is installed for all users (may need to reboot for it to take effect globally),  
Click Start, type `CMD` and on the right is the link `Run as Administrator`, click on it and enter Administrator password.  
In the `CMD` window, type these 3 DOS commands to install the dependencies required by `create-json.py` :  
```
pip3 install pymediainfo
pip3 install requests
pip3 install socket
```

### Download/Extract/Edit source files

Choose a folder to point the IIS default web page to, eg `C:\IIS` and create it eg `MKDIR C:\IIS`  
Right-click on that folder, choose Properties, Security Tab, and edit so that `Everyone` has full control, Apply and OK.  
Download the latest released .zip source code from `https://github.com/hydra3333/Pi4CC/releases`  
Extract the main folder underneath your chosen folder eg `C:\IIS` and RENAME that folder that it so it becomes `Pi4CC` eg like `C:\IIS\Pi4CC`  

Ensure you have a fixed `IPv4 address` ... usually use you router's `DHCP` settings and your PC's mac address to reserve one.  
Check the fixed IP address - in a `CMD` window, use command `IPCONFIG` to check the IPv4 address `xxx.xxx.xxx.xxx`  
Check the host name - in a `CMD` window, use command `HOSTNAME` to check host name, eg `3900X`.  

Start Windows Explorer and navigate to your chosen folder eg `C:\IIS\Pi4CC`  

Use a text editor to Edit file `index.html`  
Find the line containing `http://10.0.0.6/Pi4CC/imagefiles/free-boat_02.jpg` and change the IP address to YOUR fixed IP address, eg `http://10.0.0.4/Pi4CC/imagefiles/free-boat_02.jpg`  
Save the change to that file and exit editing that file.  

Use a text editor to Edit file `CastVideos.js`  
Find the line containing `http://10.0.0.6/Pi4CC/imagefiles/free-boat_02.jpg` and change the IP address to YOUR fixed IP address, eg `http://10.0.0.4/Pi4CC/imagefiles/free-boat_02.jpg`  
Save the change to that file and exit editing that file.  

Use a text editor to Edit file `reload_media.js.sh.bat`  
Find the line containing just `G:` and change the drive letter to the drive of the chosen folder, eg `C:`  
Find the line containing `G:\000-Development\IIS\Pi4CC` and change all occurences to your chosen folder containing this web stuff, eg `C:\IIS\Pi4CC`  
Find the line containing `T:\HDTV\autoTVS-mpg\Converted` and change it to the root disk/folder full of subdirectories and `.mp4` files, eg `T:\mp4library` ... later this folder will also be moninated as a virtual directory in IIS.  
Save the change to that file and exit editing that file.  
Double-click file `reload_media.js.sh.bat` to run it  
Check the logfile `create-json.log` in the chosen folder containing this web stuff.  

Create a scheduled task to run the reload task every night at 4:00 am.  
Try this command in a `CMD` window, subtituting your chosen folder for `G:\000-Development\IIS\Pi4CC\`  
```
schtasks.exe /create /SC DAILY /TN "Pi4CC_reload_media.js" /TR "G:\000-Development\IIS\Pi4CC\reload_media.js.sh.bat" /ST 04:00 /F
```  
Click Start, type `Sch` and click on `Task Scheduiler` to open it and view the scheduled task you just created.  It'll only run if you leave yourself logged into the PC overnight though.  
Find and right click on task `Pi4CC_reload_media.js` and choose Properties and poke around, adjusting as appropriate to your circumstances. Close Properties.  
Right-click on the task and choose `Run`.  
Check the logfile `create-json.log` in the chosen folder containing this web stuff.  

### Install IIS in Windows 10

Start `Control Panel`,` Programs and Features`,  
Click on link on left `Turn Windows features on or off` and enter Administrator password  
Expand `Internet Information Services`, then  
Tick `World Wide Web Services`  
Under `Web Management Tools` tick `IIS Management Console`, tick `IIS Management Scripts and tools`  
Click OK to install `IIS`  

### Configure IIS in Windows 10

Click Start, type the word `IIS` and see `Internet Information Services (IIS) Manager` appear,
and on the right is the link `Run as Administrator`,  
Click on it and enter Administrator password.  

On the left, expand the `server name`, then expand `sites`, then expand `Default Web Site`.  

On the left, click on the top level server name, eg `3900X`, to highlight it.  
Find the `Server Certificates` icon and double-click on it.  
On the right is a link `Create Self-Signed Certificate` and click on only that one.  
Enter the `server name` for the certificate, eg `3900X`, choose `Web Hosting` from the drop-down `certificate store`, and click OK.  
The list of certificates should now show the new `self-signed certificate`.  

On the left, click on the top level `server name`, eg `3900X`, to highlight it.  
Find the `Directory Browsing` icon and double-click on it.  
Tick the top 5 and click Apply.  

On the right, click on link `Retsart` to restart IIS.  

On the left, click on `Default Web Site`, to highlight it.  
Find the `Directory Browsing` icon and double-click on it.  
Tick the top 5 items and click Apply.  

On the left, click on `Default Web Site`, to highlight it.  
Find the `SSL settings` icon and double-click on it.  
Ensure `Require SSL` is unticked.  
Ensure `Client Certificates` is set to `Ignore`.  
Click Apply.  

On the left, click on `Default Web Site`, to highlight it.  
On the right, click on link `Basic Settings`  
In `Physical path:` choose the top level folder you chose earlier, eg `C:\IIS`  
Click on `Test Settings` button - Authenticalion should be OK, Authorization should be `unable to verfy access`, click Close.  
Click OK to set the new settings.  

On the left, click on `Default Web Site`, to highlight it.  
On the right, click on link `Bindings`  
We need to add 4 entries, 2 of which are based on your fixed IPv4 address and 2 on host name.  
(in a `CMD` window, use command `IPCONFIG` to check the IPv4 address `xxx.xxx.xxx.xxx`).  
(in a `CMD` window, use command `HOSTNAME` to check host name, eg `3900X`).  
Click the Add button each time to add the 4 entries to look like these:  
```
Type: https, IP Address: All Unassigned`,                 Port: 443, Host name: <host name, eg 3900X>
Type: https, IP Address: <the IPv4 address xx.xx.xx.xx>,  Port: 443, Host name: <leave it empty>
Type: http,  IP Address: All Unassigned`,                 Port: 80,  Host name: <host name, eg 3900X>
Type: http,  IP Address: <the IPv4 address xx.xx.xx.xx>,  Port: 80,  Host name: <leave it empty>
```  
Check the 4 entries you look a bit like the above  
Click the Close button.  

On the left, click on `Default Web Site`, to highlight it.  
On the right, click on link `Advanced Settings`.  
Check the `Physical Path` is where you need it to be, if not go back to the start of configuring and begin again.  
Expand `Behaviour` to then see `Enabled Protocols`.  
Click on `Enabled Protocols` and change the value on the right to be like this: `https,http`  
Click OK.  

On the left, click on `Default Web Site`, to highlight it.  
`Right click` on `Default Web Site` and choose `Add Virtual Directory`  
In `Alias`, enter `mp4library`  
In `Physical path`, choose the root disk/folder where we've pre-created a disk/folder full of subdirectories and `.mp4` files  
Click OK  
Notice `mp4library` now appears as a "link" under `Default Web Site`  

On the right, click on link `Retsart` to restart IIS.  

On the left, click on `Default Web Site` to highlight it.  
On the right, click on link `Explore` to open `Windows Explorer` and check it's the correct place.  

On the left, click on `mp4library` under `Default Web Site`, to highlight it.  
On the right, click on link `Explore` to open `Windows Explorer` and check it's the correct place with your `.mp4` files in it.  

Close the `IIS Manager`.  

### Test it

Open a `Chrome browser` and use `HTTPS` and the fixed IP address to view the web page,  
eg `https://xxx.xxx.xxx.xxx/Pi4CC`  

Note 1: due to the `self-signed certificate` it will show the site as insecure (who cares, it is your site in your own LAN)  
and may prompt you for permission to proceed to the website - accept it and proceed.  

Note 2: if you used `HTTPS`, the `chromecast icon` will be present (if you use plain `http` it will not appear ... google code requires it).  

Open a `Chrome browser` and use `HTTP` or `HTTPS` and the fixed IP address to browse your `Virtual Directory` of `.mp4` files,  
eg `https://xxx.xxx.xxx.xxx/mp4library`  
