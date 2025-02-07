# Set Variables
$Path = Join-Path -Path $HOME -ChildPath "\Documents\YouTube"
$exe = Join-Path -Path $Path -ChildPath "\yt-dlp.exe"
$val = 0
$url = ""

# Switch to directory with executable
Set-Location $Path

# Remove old executable
Remove-Item yt-dlp.exe

# Download new executable
Invoke-WebRequest https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -OutFile $exe


while($val -ne 1) {
    # Ask the user if they are downloading audio or video
    $Type = Read-Host "Audio or Video?"

    # Download audio
    if($Type -eq "audio") {
        $url = Read-Host "Enter URL Here"
        ./yt-dlp.exe -x -f 'ba' --audio-format mp3 -o $HOME'\Music\YouTube\output\%(title)s.%(ext)s' $url
        $val++
    }
    # Download video
    elseif($Type -eq "video"){
        $url = Read-Host "Enter URL Here"
        ./yt-dlp.exe -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' -o $HOME'\Video\output\%(title)s.%(ext)s' $url
        $val++
    }
    else {
        Write-Output "Response must be 'Audio' or 'Video'!"
        continue
    }
}