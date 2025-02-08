#!/bin/bash

# Define variables
current_dir="$PWD"
exe_location="$current_dir"/bin/yt-dlp
ffmpeg_location=/usr/bin/ffmpeg
audio_dir="$current_dir"/audio
video_dir="$current_dir"/video
val=0
url=""
type=""

# Function to hold audio download command
audio_dl () {
    "$exe_location" -x -f 'ba' --audio-format mp3 -o "$audio_dir/%(title)s.%(ext)s" "$url"
}

# Function to hold video download command
video_dl () {
    "$exe_location" -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' -o "$video_dir/%(title)s.%(ext)s" "$url"
}

# Check if ffmpeg is installed
if [ ! "$ffmpeg_location" ]; then
    echo "Missing dependency ffmpeg"
    exit 1
fi 

# Remove executable
if [ "$exe_location" ]; then
    rm "$exe_location"
fi

# Download new executable
wget -q -O "$exe_location" https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp

# Make executable executable
chmod +x "$exe_location"

# Check if audio directory exists, if not, create it
if [ ! "$audio_dir" ]; then
    mkdir audio
fi

# Check if video directory exists, if not, create it
if [ ! "$video_dir" ]; then
    mkdir video
fi

# While loop to contain download logic
while [ "$val" -ne 1 ]; do
    # Ask user if they want to download audio or video
    read -p "Audio or Video?: " type

    # Download audio
    if [ "$type" = "audio" ]; then
        read -p "Enter URL Here: " url
        audio_dl
        val=1
    # Download video
    elif [ "$type" = "video" ]; then
        read -p "Enter URL Here: " url
        video_dl
        val=1
    # If invlaid response is given, start over
    else
        echo "Must be 'Audio' or 'Video'!"
        continue
    fi
done

# If you made it here you get a sweet exit code 0
exit 0