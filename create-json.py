#!/usr/bin/env python3
#
# sudo apt install mediainfo
# pip3 install pymediainfo
#
# Create a JSON file of media in a folder tree, PRE-SORTED IN FOLDER ORDER (the code which uses this depends on that).
# The JSON file produced can be consumed by variants of the Google Chromecast example CastVideos-chrome (2019.12.10)
# which can be found at https://github.com/googlecast/CastVideos-chrome
#
# Invoke this script from the commandline like
#    ./2019.12.09-create-json.py --source_folder /mnt/mp4library/mp4library --filename-extension mp4 --json_file /var/www/Pi4CC/media.js 
#   
import os
import fnmatch
import argparse
from collections import defaultdict
from requests.utils import requote_uri
from pymediainfo import MediaInfo
#
def find_matching_files(foldername, file_pattern):
    # foldername could be a relative path, so transform it into an absolute path
    foldername = os.path.abspath(foldername)
    foldername_to_matched_files = defaultdict(list)
    for root, _, files in os.walk(foldername):
        for file in files:
            if fnmatch.fnmatch(file.lower(), file_pattern.lower()):
                foldername_to_matched_files[root].append(file)
    return foldername_to_matched_files
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--source_folder', default='/mnt/mp4library/mp4library')
    parser.add_argument('-x', '--filename-extension', default='mp4')
    parser.add_argument('-j', '--json_file', default='/var/www/Pi4CC/media.js')
    args = parser.parse_args()
    #
    print (f"Finding files '{args.source_folder}/*.{args.filename_extension.lower()}")
    the_files_dict = find_matching_files(args.source_folder, f'*.{args.filename_extension.lower()}')
    print (f"Found   files '{args.source_folder}/*.{args.filename_extension.lower()}")
    #
    # list the directories & files
    #
    cc=0
    #for record_number, (the_folder, the_filenames) in enumerate(sorted(the_files_dict.items(),key=lambda i: i[0].casefold())):
    for record_number, (the_folder, the_filenames) in enumerate(sorted(the_files_dict.items(),key=lambda i: i[0].lower())):
        #print(f"-----record {record_number}---{the_folder} ... files={len(the_filenames)}")
        for c,the_filename in enumerate(the_filenames):
            #print(f"mp4 File {c}---{the_filename}")
            cc=cc+1
    print (f'Total count of {args.filename_extension.lower()} files found: {cc}')
    #
    # Produce the JSON file media.js of the directories & files
    #
    print (f"Creating JSON file: {args.json_file}")
    cc = 0
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
        txt_part_url = part_url.replace("'","-")
        #print(f"        the_folder={the_folder}")
        #print(f"args.source_folder={args.source_folder}")
        #print(f"          part_url={part_url}")
        #print(f"      txt_part_url={txt_part_url}")
        jf.write(f"      // ----- START of folder({record_number}) {part_url} ... files={len(the_filenames)} \n")
        for c,the_filename in enumerate(sorted(the_filenames,key=lambda i: i[0].casefold())):
        #for c,the_filename in enumerate(sorted(the_filenames,key=lambda i: i[0].lower())):
            the_media_file = the_folder + "/" + the_filename
            #print(f"        file='{the_media_file}'")
            media_info = MediaInfo.parse(the_media_file)
            video_resolution = ""
            video_duration = ""
            video_codec = ""
            audio_codec = ""
            for track in media_info.tracks:  # #for k in track.to_data().keys():
                #    print("{}.{}={}".format(track.track_type,k,track.to_data()[k]))
                if track.track_type == 'Video':
                    #print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                    #print("{} width                 {}".format(track.track_type,track.to_data()["width"]))
                    #print("{} height                {}".format(track.track_type,track.to_data()["height"]))
                    #print("{} duration              {}s".format(track.track_type,track.to_data()["duration"]/1000.0))
                    #print("{} duration              {}".format(track.track_type,track.to_data()["other_duration"][3][0:8]))
                    #print("{} other_format          {}".format(track.track_type,track.to_data()["other_format"][0]))
                    #print("{} codec_id              {}".format(track.track_type,track.to_data()["codec_id"]))
                    #print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                    video_duration = track.to_data()["other_duration"][3][0:8]
                    video_resolution = "{}x{}".format(track.to_data()["width"],track.to_data()["height"])
                    video_codec = track.to_data()["other_format"][0]
                elif track.track_type == 'Audio':
                    #print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                    #print("{} format                {}".format(track.track_type,track.to_data()["format"]))
                    #print("{} codec_id              {}".format(track.track_type,track.to_data()["codec_id"]))
                    #print("{} channel_s             {}".format(track.track_type,track.to_data()["channel_s"]))
                    #print("{} other_channel_s       {}".format(track.track_type,track.to_data()["other_channel_s"][0]))
                    #print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                    audio_codec = track.to_data()["format"]
            title,ignore_me = os.path.splitext(the_filename.replace("'","-"))  # root,ext = os.path.splitext(path) 
            source = requote_uri("http://10.0.0.6/mp4library" + part_url + the_filename)
            subtitle = source
            thumb = "".replace("'","-")
            jf.write("      {\n")
            jf.write(f"        'title'       : '{title}',\n")
            jf.write(f"        'subtitle'    : '{subtitle}',\n")
            jf.write(f"        'sources'     : ['{source}',],\n")
            jf.write(f"        'thumb'       : '',\n")
            jf.write(f"        'duration'    : '{video_duration}',\n")
            jf.write(f"        'resolution'  : '{video_resolution}',\n")
            jf.write(f"        'video_codec' : '{video_codec}',\n")
            jf.write(f"        'audio_codec' : '{audio_codec}',\n")
            jf.write(f"        'folder'      : '{txt_part_url}',\n")
            jf.write("      },\n")
            cc=cc+1
        jf.write(f"      // ----- END   of folder({record_number}) {part_url} ... files={len(the_filenames)} \n")
    jf.write("     ]\n")
    jf.write("  }]\n")
    jf.write("};\n")
    jf.write("export { mediaJSON }\n")
    jf.close()
    print (f"Created  JSON file: {args.json_file}")
    print (f"Total count of {args.filename_extension.lower()} files linked: {cc}")