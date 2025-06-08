# Set Variables
$current_dir = Get-Location
$bin_dir = Join-Path -Path $current_dir -ChildPath '\bin'
$sig_dir = Join-Path -Path $current_dir -ChildPath '\sig'
$bin_test = Test-Path -Path $bin_dir
$sig_test = Test-Path -Path $sig_dir
$exe_location = Join-Path -Path $bin_dir -ChildPath '\yt-dlp.exe'
$exe_test = Test-Path -Path $exe_location
$ffmpeg_location = Join-Path -Path $bin_dir -ChildPath '\ffmpeg.exe'
$ffplay_location = Join-Path -Path $bin_dir -ChildPath '\ffplay.exe'
$ffprobe_location = Join-Path -Path $bin_dir -ChildPath '\ffprobe.exe'
$ffmpeg_dll_location = Join-Path -Path $bin_dir -ChildPath '\*.dll'
$ffmpeg_test = Test-Path -Path $ffmpeg_location
$audio_dir = Join-Path -Path $current_dir -ChildPath '\audio'
$video_dir = Join-Path -Path $current_dir -ChildPath '\video'
$work_dir = Join-Path -Path $current_dir -ChildPath '\work'
$ffmpeg_zip_work_location = Join-Path -Path $work_dir -ChildPath 'ffmpeg.zip'
$ffmpeg_work_location = Join-Path -Path $work_dir -ChildPath '\ffmpeg-master-latest-win64-gpl-shared\bin\*'
$test_audio_dir = Test-Path -Path $audio_dir
$test_video_dir = Test-Path -Path $video_dir
$audio_title = Join-Path -Path $audio_dir -ChildPath "'\%(title)s.%(ext)s'"
$video_title = Join-Path -Path $video_dir -ChildPath "'\%(title)s.%(ext)s'"
$val = 0
$url = ""
$dl_val = 0
$yt_sig_location = Join-Path -Path $current_dir -ChildPath '\sig\yt-dlp-windows.sha512'
$yt_current_sig = certutil.exe -hashfile $exe_location SHA512
$ffmpeg_sig_location = Join-Path -Path $current_dir -ChildPath '\sig\ffmpeg-windows.sha256'
$ffmpeg_current_sig = certutil.exe -hashfile $ffmpeg_location SHA256
$yt_sig_eq_check = Select-String -Path $yt_sig_location -Pattern $yt_current_sig -SimpleMatch -Quiet
$ffmpeg_sig_eq_check = Select-String -Path $ffmpeg_sig_location -Pattern $ffmpeg_current_sig -SimpleMatch -Quiet
$ffmpeg_link = "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip" 
$yt_dlp_link = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" 
$batch_dl_file = Join-Path -Path $current_dir -ChildPath 'batch-download.txt'

function Get-FFmpeg {

    param (
       $ffmpeg_link 
    )

    # Create work directory to extract archive with new executable
    New-Item -Path $current_dir -Name "work" -ItemType "directory"
    Invoke-WebRequest $ffmpeg_link -OutFile $ffmpeg_zip_work_location
    # Extract archive to work directory
    Expand-Archive -Path $ffmpeg_zip_work_location -DestinationPath $work_dir

    # Move new executable to correct location
    Move-Item -Path $ffmpeg_work_location -Destination $bin_dir 

    # Remove work directory
    Remove-Item -Recurse -Force $work_dir

    Write-Output "Done!"
    
}

function Convert-BatchLink {

    param (
        $dl_val
    )

    while($dl_val -ne 1){
        # Ask the user if they are downloading audio or video
        $Format = Read-Host "Audio or Video?"

        # Download audio
        if($Format -eq "audio") {
            Invoke-Expression "$exe_location -x -f 'ba' --audio-format mp3 --windows-filenames -o $audio_title -a $batch_dl_file"
            $dl_val++
        }
        # Download video
        elseif($Format -eq "video"){
            Invoke-Expression "$exe_location -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' --windows-filenames --sponsorblock-remove sponsor,selfpromo,interaction -o $video_title -a $batch_dl_file"
            $dl_val++
        }
        else {
            Write-Output "Response must be 'Audio' or 'Video'!"
            continue
        }
    }
}

function Convert-Link {
    
    param (
        $dl_val
    )

    while($dl_val -ne 1) {
        # Ask the user if they are downloading audio or video
        $Format = Read-Host "Audio or Video?"

        # Download audio
        if($Format -eq "audio") {
            $url = Read-Host "Enter URL Here"
            Invoke-Expression "$exe_location -x -f 'ba' --audio-format mp3 --windows-filenames -o $audio_title $url"
            $dl_val++
        }
        # Download video
        elseif($Format -eq "video"){
            $url = Read-Host "Enter URL Here"
            Invoke-Expression "$exe_location -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' --windows-filenames --sponsorblock-remove sponsor,selfpromo,interaction -o $video_title $url"
            $dl_val++
        }
        else {
            Write-Output "Response must be 'Audio' or 'Video'!"
            continue
        }
    }   
}
    
if($bin_test -ne $true) {
    Write-Output "bin directory not found! Creating now!"
    New-Item -Path $current_dir -Name "bin" -ItemType "directory" 
}

if($sig_test -ne $true) {
    Write-Output "sig directory not found! Creating now!"
    New-Item -Path $current_dir -Name "sig" -ItemType "directory"   
}

if($ffmpeg_test -eq $true){
    # Remove old ffmpeg signature
    Remove-Item $ffmpeg_sig_location
} else {
    Write-Output "ffmpeg executable not found! Downloading now..."
    Get-FFmpeg($ffmpeg_link)
}

if($exe_test -eq $true) {
    # Remove old yt-dlp signature 
    Remove-Item $yt_sig_location
} else {
    Write-Output "yt-dlp executable not found! Downloading now..."
    Invoke-WebRequest $yt_dlp_link -OutFile $exe_location
    Write-Output "Done!"
}

Write-Output "Updating ffmpeg signature..."
# Download new ffmpeg signature
Invoke-WebRequest https://github.com/arthur-taft/ffmpeg-latest-signatures/releases/latest/download/ffmpeg-windows.sha256 -OutFile $ffmpeg_sig_location
Write-Output "Done!"

Write-Output "Updating yt-dlp signature..."
# Download new yt-dlp signature
Invoke-WebRequest https://github.com/arthur-taft/yt-dlp-signatures/releases/latest/download/yt-dlp-windows.sha512 -OutFile $yt_sig_location
Write-Output "Done!"

if($yt_sig_eq_check -ne $true) {
    Write-Output "Old version of yt-dlp found, updating now..."

    # Remove old executable
    Remove-Item $exe_location

    # Download new executable
    Invoke-WebRequest $yt_dlp_link -OutFile $exe_location 

    Write-Output "Done!"
}

if($ffmpeg_sig_eq_check -ne $true) {
    Write-Output "Old version ffmpeg found, updating now..."

    # Remove old executables
    Remove-Item $ffmpeg_location
    Remove-Item $ffprobe_location
    Remove-Item $ffplay_location

    # Remove old libraries
    Remove-Item $ffmpeg_dll_location

    Get-FFmpeg($ffmpeg_link)
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
    # Ask the user if they are performing a batch download
    $Type = Read-Host "Do you want to batch download using links in the 'batch-downloads.txt' file? (y/n)"
    
    if($Type -eq "y") {
        Convert-BatchLink($dl_val) 
        $val++
    }
    elseif($Type -eq "n") {
        Convert-Link($dl_val)
        $val++
    }
    else{
        Write-Output "Answer must be Y or N!"
        continue
    }
}