#!/bin/bash

# Cross-distro package checker and installer
check_or_install() {
    local pkg="$1"
    local pm=""

    if command -v pacman &>/dev/null; then
        pm="pacman"
        pacman -Q "$pkg" &>/dev/null

    elif command -v dpkg &>/dev/null && command -v apt &>/dev/null; then
        pm="apt"
        dpkg -s "$pkg" &>/dev/null

    elif command -v rpm &>/dev/null && command -v dnf &>/dev/null; then
        pm="dnf"
        rpm -q "$pkg" &>/dev/null

    elif command -v rpm &>/dev/null && command -v yum &>/dev/null; then
        pm="yum"
        rpm -q "$pkg" &>/dev/null

    elif command -v qlist &>/dev/null; then
        pm="emerge"
        qlist -I "$pkg" &>/dev/null

    elif command -v zypper &>/dev/null; then
        pm="zypper"
        zypper se --installed-only "$pkg" | grep -q "$pkg"

    else
        echo "Unsupported package manager" >&2
        return 2
    fi

    if [[ $? -eq 0 ]]; then
        echo "$pkg is already installed."
        return 0
    fi

    echo "Installing missing package: $pkg via $pm..."
    case "$pm" in
        pacman) sudo pacman -Sy --noconfirm "$pkg" ;;
        apt) sudo apt update && sudo apt install -y "$pkg" ;;
        dnf) sudo dnf install -y "$pkg" ;;
        yum) sudo yum install -y "$pkg" ;;
        emerge) sudo emerge "$pkg" ;;
        zypper) sudo zypper install -y "$pkg" ;;
        *) echo "Cannot install $pkg on unknown system." >&2; return 3 ;;
    esac
}

# Ensure dependencies
check_or_install wget
check_or_install ffmpeg

# Define variables
current_dir="$PWD"
exe_location="$current_dir/bin/yt-dlp"
ffmpeg_location="/usr/bin/ffmpeg"
audio_dir="$current_dir/audio"
video_dir="$current_dir/video"
val=0
dl_val=0
url=""
format=""
type=""
batch_dl_file="$current_dir/batch-dl.txt"

# Ensure bin directory exists
mkdir -p "$current_dir/bin"

# Function to download audio
audio_dl () {
    "$exe_location" -x -f 'ba' --audio-format mp3 -o "$audio_dir/%(title)s.%(ext)s" "$url"
}

audio_dl_batch () {
    "$exe_location" -x -f 'ba' --audio-format mp3 -o "$audio_dir/%(title)s.%(ext)s" -a "$batch_dl_file"
}

# Function to download video
video_dl () {
    "$exe_location" -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/bv*+ba/b" -o "$video_dir/%(title)s.%(ext)s" "$url"
}

video_dl_batch () {
    "$exe_location" -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/bv*+ba/b" --sponsorblock-remove sponsor,selfpromo,interaction -o "$video_dir/%(title)s.%(ext)s" -a "$batch_dl_file"
}

# Function to single download
single_dl ("$dl_val") {
    while [ "$dl_val" -ne 1 ]; do
        read -p "Audio or Video?: " format

        case "$format" in
            audio)
                read -p "Enter URL Here: " url
                audio_dl
                dl_val=1
                ;;
            video)
                read -p "Enter URL Here: " url
                video_dl
                dl_val=1
                ;;
            *)
                echo "❗ Must be 'audio' or 'video'!"
                ;;
        esac
    done
}
# Function to batch download
batch_dl ("$dl_val") {
    while [ "$dl_val" -ne 1 ]; do
        read -p "Audio or Video?: " format

        case "$format" in
            audio)
                audio_dl_batch
                dl_val=1
                ;;
            video)
                video_dl_batch
                dl_val=1
                ;;
            *)
                echo "Must be 'audio' or 'video'!"
                ;;
        esac
    done
}

# Remove existing executable (if it exists)
[ -f "$exe_location" ] && rm "$exe_location"

# Download yt-dlp
wget -q -O "$exe_location" https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
chmod +x "$exe_location"

# Create directories if they don't exist
mkdir -p "$audio_dir"
mkdir -p "$video_dir"

# Download loop
while [ "$val" -ne 1 ]; do
    read -p "Batch Download? (y/n): " type
    case "$type" in
        y)
            batch_dl
            val=1
            ;;
        n)
            single_dl
            val=1
            ;;
        *)
            echo "Must be 'y' or 'n'!"
            ;;
    esac
done
exit 0