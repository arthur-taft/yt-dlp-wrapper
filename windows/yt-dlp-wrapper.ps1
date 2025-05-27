# Set Variables
$current_dir = Get-Location
$exe_location = Join-Path -Path $current_dir -ChildPath '\bin\yt-dlp.exe'
$ffmpeg_location = Join-Path -Path $current_dir -ChildPath '\bin\ffmpeg.exe'
$audio_dir = Join-Path -Path $current_dir -ChildPath '\audio'
$video_dir = Join-Path -Path $current_dir -ChildPath '\video'
$work_dir = Join-Path -Path $current_dir -ChildPath '\work'
$ffmpeg_zip_work_location = Join-Path -Path $work_dir -ChildPath 'ffmpeg.zip'
$ffmpeg_work_location = Join-Path -Path $work_dir -ChildPath '\ffmpeg-master-latest-win64-gpl-shared\bin\ffmpeg.exe'
$test_audio_dir = Test-Path -Path $audio_dir
$test_video_dir = Test-Path -Path $video_dir
$val = 0
$url = ""
$yt_sig_location = Join-Path -Path $current_dir -ChildPath '\sig\SHA2-512SUMS'
$yt_current_sig = certutil.exe -hashfile $exe_location SHA512
$ffmpeg_sig_location = Join-Path -Path $current_dir -ChildPath '\sig\checksums.sha256'
$ffmpeg_current_sig = certutil.exe -hashfile $ffmpeg_location SHA256
$yt_sig_eq_check = Select-String -Path $yt_sig_location -Pattern $yt_current_sig -SimpleMatch -Quiet
$ffmpeg_sig_eq_check = Select-String -Path $ffmpeg_sig_location -Pattern $ffmpeg_current_sig -SimpleMatch -Quiet

# Remove old ffmpeg signature
Remove-Item $ffmpeg_sig_location

# Remove old yt-dlp signature 
Remove-Item $yt_sig_location

Write-Output "Updating ffmpeg signature..."
# Download new ffmpeg signature
Invoke-WebRequest https://github.com/arthur-taft/ffmpeg-latest-signatures/releases/latest/download/checksums.sha256 -OutFile $ffmpeg_sig_location
Write-Output "Done!"

Write-Output "Updating yt-dlp signature..."
# Download new yt-dlp signature
Invoke-WebRequest https://github.com/arthur-taft/yt-dlp-signatures/releases/latest/download/SHA2-512SUMS -OutFile $yt_sig_location
Write-Output "Done!"

if($yt_sig_eq_check -ne $true) {
    Write-Output "Old version of yt-dlp found, updating now..."

    # Remove old executable
    Remove-Item $exe_location

    # Download new executable
    Invoke-WebRequest https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -OutFile $exe_location

    Write-Output "Done!"
}

if($ffmpeg_sig_eq_check -ne $true) {
    Write-Output "Old version ffmpeg found, updating now..."

    # Remove old executable
    Remove-Item $ffmpeg_location

    # Create work directory to extract archive with new executable
    New-Item -Path $current_dir -Name "work" -ItemType "directory"

    # Download new archive
    Invoke-WebRequest https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip -OutFile $ffmpeg_zip_work_location

    # Extract archive to work directory
    Expand-Archive -Path $ffmpeg_zip_work_location -DestinationPath $work_dir

    # Move new executable to correct location
    Move-Item -Path $ffmpeg_work_location -Destination $ffmpeg_location

    # Remove work directory
    Remove-Item -Recurse -Force $work_dir

    Write-Output "Done!"
}

# Check if audio output directory exists, if not, create it
if($test_audio_dir -eq $false) {
    Write-Output "Audio directory not found!"
    Write-Output "Creating now..."
    New-Item -Path $current_dir -Name "audio" -ItemType "directory"
    Write-Output "Done!"
}

# Check if video output directory exists, if not, create it
if($test_video_dir -eq $false) {
    Write-Output "Video directory not found!"
    Write-Output "Creating now..."
    New-Item -Path $current_dir -Name "video" -ItemType "directory"
    Write-Output "Done!"
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