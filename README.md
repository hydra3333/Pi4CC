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
1. A Raspberry Pi 4 server called Pi4CC (or whatever name you specify) with relevant software and settings
2. A USB3 (10Tb ?) external drive with a fixed mount point etc
3. A miniDLNA server
4. A SAMBA file-sharing software compatible with Windows file shares
5. An Apache2 web server, with a self-signed SSL/TLS cerfificate
6. A local Pi4CC website (and bits) and companion python3 script and relevant crontab entries to re-index nightly

# Installation

1. Install and configure your Raspberry Pi 4 4Gb and set it to always to boot to GIU and autologin
   - it is close enough to safe to autologin since the Pi is only visible inside your "secure" home LAN
   - (the GUI should be left to boot and run, even in a headless state later)
2. Check, perhaps in the GUI tool Raspberry Pi Configuration,
   -  its hostname is short and easy and has no spaces or special characters (it will be used as the website name)
   - "login as user pi" is ticked
   - "wait for network" is ticked
   - "splash screen" is disabled
   -  VNC is enabled
   -  SSH is enabled
   - GPU memory is 384k
   - "localisation" tab is used to check/configure your timezone/locale etc
3. Also check the Pi has a fixed IP address, perhaps by setting your home router's DHCP facility to recognise the Pi's mac address and provide a fixed IP address
4. Clone the respository to the Desktop of the Pi and copy the setup files to the Desktop
   - start a Terminal and do this:
   ```
   cd ~/Desktop
   sudo apt install -y git
   git clone https://github.com/hydra3333/Pi4CC.git
   cp -fv ./Pi4CC/setup_0.sh ./
   cp -fv ./Pi4CC/setup_1.sh ./
   chmod +777 *.sh
   ```
5. Do the installation (it should be re-startable, feel free to "Control C" and re-start if feel uncomfortable)
   - start a Terminal and do this:
   ```
   cd ~/Desktop
   ./setup_0.sh
   ```
   - answer any prompts, eg
     * `This server_name` it's best to enter the hostname of the Pi therehere
     * `This server_name` it's best to enter the hostname of the Pi therehere
     * `This server_name` it's best to enter the hostname of the Pi therehere
     * `This server_name` it's best to enter the hostname of the Pi therehere







# Test it out on a PC first ?

Perhaps consider usng Raspberry PI Desktop in VMware Player on a PC ?

https://www.raspberrypi.org/forums/viewtopic.php?f=116&t=200252&p=1588362#p1586023

You may have "fun" trying to finding and its IP address for remote https connections into it, have a try or
use the chromium browser inside the Pi.





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
