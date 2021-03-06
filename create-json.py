#!/usr/bin/env python3
#
# for Linux:
# sudo apt install mediainfo
# pip3 install pymediainfo
# pip3 install requests
# pip3 install socket
#
# for Win10:
# start an cmd window in ADMINISTRATOR
#?? sudo apt install mediainfo
# pip3 install pymediainfo
# pip3 install requests
# pip3 install socket
#
# Create a JSON file of media in a folder tree, PRE-SORTED IN FOLDER ORDER (the code which uses this depends on that).
# The JSON file produced can be consumed by variants of the Google Chromecast example CastVideos-chrome (2019.12.10)
# which can be found at https://github.com/googlecast/CastVideos-chrome
#
# Invoke this script from the commandline like
#
# Linux:
#    ./create-json.py --source_folder /mnt/mp4library/mp4library --filename-extension mp4 --json_file /var/www/Pi4CC/media.js --host_name Pi4CC --host_ip 10.0.0.6
# Windows: 
#    python G:\000-Development\IIS\Pi4CC\create-json.py --source_folder T:\HDTV\autoTVS-mpg\Converted --filename-extension mp4 --json_file G:\000-Development\IIS\Pi4CC\media.js
#    Assuming:
#       in IIS we have setup the Default Web Site pointing to folder "G:\000-Development\IIS"
#       in IIS we have setup Default Web Site Virtual Directory "mp4library" pointing to folder "T:\HDTV\autoTVS-mpg\Converted"
#       we have extracted/setup the website in folder "G:\000-Development\IIS\Pi4CC"
#   
import sys
import os
import platform
import subprocess
import socket
import fnmatch
import argparse
import datetime
from collections import defaultdict
from requests.utils import requote_uri
from pymediainfo import MediaInfo
#
def find_matching_files(foldername, file_pattern):
    # foldername could be a relative path, so transform it into an absolute path
    foldername = os.path.abspath(foldername)
    foldername_to_matched_files = defaultdict(list)
    for root, _, files in os.walk(foldername,topdown=True,followlinks=True):
        for file in files:
            if fnmatch.fnmatch(file.lower(), file_pattern.lower()):
                foldername_to_matched_files[root].append(file)
    return foldername_to_matched_files
if __name__ == '__main__':
    host_platform = platform.system()
    if host_platform.lower() == 'Windows'.lower():  # Windows
        default_host_name = socket.getfqdn()
        default_host_ip = socket.gethostbyname(default_host_name)
        default_source_folder = 'T:\\HDTV\\autoTVS-mpg\\Converted' # only here as a constant do we need the double backslash
        default_filename_extension = 'mp4'
        default_json_file = 'G:\\000-Development\\IIS\\Pi4CC\\media.js' # only here as a constant do we need the double backslash
    else:                                           # assume some form of Linux
        default_host_name = subprocess.check_output(['hostname', '--fqdn']).decode('utf-8')[:-1].replace(' ', '') # this [:-1] removes trailing EOL
        default_host_ip = subprocess.check_output(['hostname', '-I']).decode('utf-8')[:-1].replace(' ', '') # this [:-1] removes trailing EOL
        default_source_folder = '/mnt/mp4library/mp4library'
        default_filename_extension = 'mp4'
        default_json_file = '/var/www/Pi4CC/media.js'
    #print(f"{datetime.datetime.now()} debug: if unspecified, default_host_name='{default_host_name}'")
    #print(f"{datetime.datetime.now()} debug: if unspecified, default_host_ip={default_host_ip}")
    #print(f"{datetime.datetime.now()} debug: if unspecified, default_source_folder={default_source_folder}")
    #print(f"{datetime.datetime.now()} debug: if unspecified, default_filename_extension={default_filename_extension}")
    #print(f"{datetime.datetime.now()} debug: if unspecified, default_json_file={default_json_file}")
    #sys.exit()
    #
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--source_folder', default=f'{default_source_folder}')
    parser.add_argument('-x', '--filename-extension', default=f'{default_filename_extension}')
    parser.add_argument('-j', '--json_file', default=f'{default_json_file}')
    parser.add_argument('-n', '--host_name', default=f"{default_host_name}")
    parser.add_argument('-i', '--host_ip', default=f"{default_host_ip}")
    args = parser.parse_args()
    print(f"{datetime.datetime.now()} debug: args.host_name='{args.host_name}'")
    print(f"{datetime.datetime.now()} debug: args.host_ip={args.host_ip}")
    print(f"{datetime.datetime.now()} debug: args.source_folder={args.source_folder}")
    print(f"{datetime.datetime.now()} debug: args.default_filename_extension={args.filename_extension}")
    print(f"{datetime.datetime.now()} debug: args.json_file={args.json_file}")
    #sys.exit()
    #
    print(f"{datetime.datetime.now()} Started ...", flush=True)
    print(f"{datetime.datetime.now()} Using target host_name='{args.host_name}' and target host_ip='{args.host_ip}' ...", flush=True)
    print (f"{datetime.datetime.now()} Finding files '{args.source_folder}/*.{args.filename_extension.lower()}", flush=True)
    the_files_dict = find_matching_files(args.source_folder, f'*.{args.filename_extension.lower()}')
    print(f"{datetime.datetime.now()} Found   files '{args.source_folder}/*.{args.filename_extension.lower()}", flush=True)
    #
    # list the directories & files
    #
    cc=0
    #for record_number, (the_folder, the_filenames) in enumerate(sorted(the_files_dict.items(),key=lambda i: i[0].casefold())):
    for record_number, (the_folder, the_filenames) in enumerate(sorted(the_files_dict.items(),key=lambda i: i[0].lower())):
        #print(f"{datetime.datetime.now()} -----record {record_number}---{the_folder} ... files={len(the_filenames)}", flush=True)
        for c,the_filename in enumerate(the_filenames):
            #print(f"{datetime.datetime.now()} mp4 File {c}---{the_filename}", flush=True)
            cc=cc+1
    print(f"{datetime.datetime.now()} Total count of {args.filename_extension.lower()} files found: {cc}", flush=True)
    #
    # Produce the JSON file media.js of the directories & files
    #
    print(f"{datetime.datetime.now()} Creating JSON file: {args.json_file}", flush=True)
    cc = 0
    cc_i = 0
    jf_i = open('./media_interlaced_files.log','w')
    jf = open(args.json_file,'w')
    jf.write("'use strict';\n")
    jf.write("/**\n")
    jf.write("* Hardcoded JSON file of media objects acceptable to the Google Chromecast example CastVideos-chrome (2019.12.10)\n")
    jf.write("* which can be found at https://github.com/googlecast/CastVideos-chrome \n")
    jf.write("* The media objects are PRE_SORTED IN CASE-INDEPENDENT FOLDER ORDER \n")
    jf.write("* (some variants of the example code which consume this JSON file can depend on that folder sort order).\n")
    jf.write("*/\n")
    jf.write("let mediaJSON = {\n")
    jf.write("  'categories': [{\n")
    jf.write("    'name':   'Movies',\n")
    jf.write("    'videos': [\n")
    for record_number, (the_folder, the_filenames) in enumerate(sorted(the_files_dict.items(),key=lambda i: i[0].casefold())):
    #for record_number, (the_folder, the_filenames) in enumerate(sorted(the_files_dict.items(),key=lambda i: i[0].lower())):
        # strip the source folder from the current folder and use that as part of the URL
        part_url = the_folder.replace(f"{args.source_folder}","",1) + "/"
        #if part_url == "" :
        #    part_url = "/"
        part_url = part_url.replace("\\","/") # to cater for Windows backslashes
        txt_part_url = part_url.replace("'","-")
        #print(f"        the_folder={the_folder}", flush=True)
        #print(f"args.source_folder={args.source_folder}", flush=True)
        #print(f"          part_url={part_url}, flush=True")
        #print(f"      txt_part_url={txt_part_url}", flush=True)
        jf.write(f"      // ----- START of folder({record_number}) {part_url} ... files={len(the_filenames)} \n")
        for c,the_filename in enumerate(sorted(the_filenames,key=lambda i: i[0].casefold())):
        #for c,the_filename in enumerate(sorted(the_filenames,key=lambda i: i[0].lower())):
            the_media_file = the_folder + "/" + the_filename
            #print(f"        file='{the_media_file}'", flush=True)
            media_info = MediaInfo.parse(the_media_file)
            video_resolution = ""
            video_duration = ""
            video_codec = ""
            video_scan_type = ""
            audio_codec = ""
            for track in media_info.tracks:  # 
                #for k in track.to_data().keys():
                #    print("{}.{}={}".format(track.track_type,k,track.to_data()[k]), flush=True)
                if track.track_type == 'Video':
                    #print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++", flush=True)
                    #print("{} width                 {}".format(track.track_type,track.to_data()["width"]), flush=True)
                    #print("{} height                {}".format(track.track_type,track.to_data()["height"]), flush=True)
                    #print("{} duration              {}s".format(track.track_type,track.to_data()["duration"]/1000.0), flush=True) # in seconds
                    #print("{} duration              {}".format(track.track_type,track.to_data()["other_duration"][3][0:8]), flush=True)
                    #print("{} other_format          {}".format(track.track_type,track.to_data()["other_format"][0]), flush=True)
                    #print("{} codec_id              {}".format(track.track_type,track.to_data()["codec_id"]), flush=True)
                    #print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++", flush=True)
                    if ( 
                         ( track.to_data()["duration"] is None ) or 
                         ( track.to_data()["other_format"] is None ) or ( track.to_data()["other_format"] == '' ) or 
                         ( track.to_data()["width"] is None ) or ( track.to_data()["width"] == '' ) or 
                         ( track.to_data()["height"] is None ) or ( track.to_data()["height"] == '' ) or 
                         ( track.to_data()["other_duration"] is None ) or ( track.to_data()["other_duration"] == '' )
                       ) :
                        video_duration = 1
                        print(f"{datetime.datetime.now()} Bung pymediainfo duration/width/height values detected in {the_filename}", flush=True)
                        for k in track.to_data().keys():
                            print("{}.{}={}".format(track.track_type,k,track.to_data()[k]), flush=True)
                    else:
                        video_duration = int(track.to_data()["duration"] / 1000.0) # track.to_data()["duration"] / 1000.0 # in seconds
                    video_duration_str = track.to_data()["other_duration"][3][0:8] # sometimes it is set even if seconds are bung
                    video_resolution = "{}x{}".format(track.to_data()["width"],track.to_data()["height"])
                    video_codec = track.to_data()["other_format"][0]
                    video_scan_type = track.to_data()["scan_type"]
                    vs_tmp = video_scan_type = track.to_data()["scan_type"]
                    if (video_scan_type != "Progressive"):
                        video_scan_type = 'Interlaced'
                elif track.track_type == 'Audio':
                    #print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                    #print("{} format                {}".format(track.track_type,track.to_data()["format"]), flush=True)
                    #print("{} codec_id              {}".format(track.track_type,track.to_data()["codec_id"]), flush=True)
                    #print("{} channel_s             {}".format(track.track_type,track.to_data()["channel_s"]), flush=True)
                    #print("{} other_channel_s       {}".format(track.track_type,track.to_data()["other_channel_s"][0]), flush=True)
                    #print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                    audio_codec = track.to_data()["format"]
            title,ignore_me = os.path.splitext(the_filename.replace("'","-"))  # root,ext = os.path.splitext(path) 
            # source = requote_uri("/mp4library" + part_url + the_filename)
            # source = requote_uri(f"http://{args.host_name}/mp4library" + part_url + the_filename)
            source = requote_uri(f"http://{args.host_ip}/mp4library" + part_url + the_filename)
            subtitle = f"{source} [{video_resolution}] [{video_codec}/{audio_codec}] [{video_duration_str}]"
            if (video_scan_type != "Progressive"): # i.e. if an Interlaced video
                cc_i = cc_i + 1
                jf_i.write(f"{the_filename} [{video_codec}/{audio_codec}] [{vs_tmp}]\n") # pre adding interlaced marker to title and subtitle
                print(f"{datetime.datetime.now()} INTERLACED VIDEO FILE detected: {the_filename} [{video_codec}/{audio_codec}] [{vs_tmp}]", flush=True)
                title  = "[Interlaced] " + title
                subtitle = "[Interlaced] " + subtitle
            #    print(f"{datetime.datetime.now()} START OF INTERLACED VIDEO FILE detected in {the_filename}", flush=True)
            #    for track in media_info.tracks:
            #        for k in track.to_data().keys():
            #            print("{}.{}={}".format(track.track_type,k,track.to_data()[k]), flush=True)
            #    print(f"{datetime.datetime.now()} END OF INTERLACED VIDEO FILE detected in {the_filename}", flush=True)            thumb = "".replace("'","-")
            thumb = "".replace("'","-")
            jf.write("      {\n")
            jf.write(f"        'title'           : '{title}',\n")
            jf.write(f"        'subtitle'        : '{subtitle}',\n")
            jf.write(f"        'sources'         : ['{source}',],\n")
            jf.write(f"        'thumb'           : '',\n")
            jf.write(f"        'duration'        : {video_duration},\n") # this MUST be a numeric field, or the consuming javascript code fails
            jf.write(f"        'duration_str'    : '{video_duration_str}',\n")
            jf.write(f"        'resolution'      : '{video_resolution}',\n")
            jf.write(f"        'video_codec'     : '{video_codec}',\n")
            jf.write(f"        'video_scan_type' : '{video_scan_type}',\n")
            jf.write(f"        'audio_codec'     : '{audio_codec}',\n")
            jf.write(f"        'folder'          : '{txt_part_url}',\n")
            jf.write("      },\n")
            cc=cc+1
            if cc % 50 == 0:
                print(f"{datetime.datetime.now()} - processed {cc} files so far...", flush=True)
        jf.write(f"      // ----- END   of folder({record_number}) {part_url} ... files={len(the_filenames)} \n")
    jf.write("     ]\n")
    jf.write("  }]\n")
    jf.write("};\n")
    jf.write("export { mediaJSON }\n")
    jf.close()
    jf_i.close()
    print(f"{datetime.datetime.now()} Created  JSON file: {args.json_file}", flush=True)
    print(f"{datetime.datetime.now()} INTERLACED video files detected: {cc_i}", flush=True)
    print(f"{datetime.datetime.now()} Total count of {args.filename_extension.lower()} files linked: {cc}", flush=True)
