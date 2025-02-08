# Set Variables
$current_dir = Get-Location
$exe_location = Join-Path -Path $current_dir -ChildPath '\bin\yt-dlp.exe'
$audio_dir = Join-Path -Path $current_dir -ChildPath '\audio'
$video_dir = Join-Path -Path $current_dir -ChildPath '\video'
$test_audio_dir = Test-Path -Path $audio_dir
$test_video_dir = Test-Path -Path $video_dir
$val = 0
$url = ""

# Remove old executable
Remove-Item $exe_location

# Download new executable
Invoke-WebRequest https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -OutFile $exe_location

# Check if audio output directory exists, if not, create it
if($test_audio_dir -eq $false) {
    New-Item -Path $current_dir -Name "audio" -ItemType "directory"
}

# Check if video output directory exists, if not, create it
if($test_video_dir -eq $false) {
    New-Item -Path $current_dir -Name "video" -ItemType "directory"
}


while($val -ne 1) {
    # Ask the user if they are downloading audio or video
    $Type = Read-Host "Audio or Video?"

    # Download audio
    if($Type -eq "audio") {
        $url = Read-Host "Enter URL Here"
        Invoke-Expression "$exe_location -x -f 'ba' --audio-format mp3 -o $audio_dir'\%(title)s.%(ext)s' $url"
        $val++
    }
    # Download video
    elseif($Type -eq "video"){
        $url = Read-Host "Enter URL Here"
        Invoke-Expression "$exe_location -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' -o $video_dir'\%(title)s.%(ext)s' $url"
        $val++
    }
    else {
        Write-Output "Response must be 'Audio' or 'Video'!"
        continue
    }
}