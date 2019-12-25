Description <TL;DR> 

   A zero-frills LAN-only Media Server using DLNA and Apache2 web server to serve up .mp4 files
   from a low-cost low-power Raspberry Pi 4 server

More Description:

How to setup a Raspberry Pi 4 (Raspbian buster) as a HOME LAN media server (only inside a home LAN) so that :-
1. via DLNA, it can be searchable and serve .mp4 files to Apps on tablets and phones and smartTVs
2. via a LAN-only web page, it can it can be searchable on tablets and phones and PCs, 
   and be able to "cast" .mp4 files to Chromecast devices connected to TVs 
   (eg a Chromecast Ultra, which can play h.265).
Hence,
3. Remember, "casting" a .mp4 files means that once a .mp4 file is cast to a Chromecast device, 
   the serving of the data in the large .mp4 video file is then directly between the 
   chromecast device and the Pi 4 (i.e. a tablet or phone or PC does not forward data packets)
   and the casting phone/tablet/PC (known as a Sender) then only chats with the chromecast device
   to control video playback.
4. After setup, the monitor/mouse/keyboard can be disconnected from the Pi4. 
5. It does NOT do any "non-Google-app" *external* connections outside your home LAN at runtime
      ... unlike Plex Media Server (search about it in the Raspberry Pi forums)
      ... unlike Kodi 
   Your list of media contents etc is NOT shared with any company or individual. 
   You are in control.
6. If you want something better and fancier, 
   look for Plex Media Server and Kodi. They're good, if you are willing to be a sharing individual.
5. This is based solely on the Google "CastVideos-chrome" example at 
      https://github.com/googlecast/CastVideos-chrome
   with "minimal" changes.

Key things installed and configured:
1. A Raspberry Pi 4 server called Pi4CC
2. miniDLNA server
3. Apache2 web server, with a self-signed SSL/TLS cerfificate
4. SAMBA file-sharing software compatible with Windows file shares
5. The Pi4CC web page with companion python3 script

Addendum:

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
