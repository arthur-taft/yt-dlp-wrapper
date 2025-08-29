import argparse
from pathlib import Path
from subprocess import run
from directories import Directories

dirs = Directories()

project_home = dirs.get_home()
audio_dir = dirs.get_audio_dir()
video_dir = dirs.get_video_dir()

audio_title = Path.joinpath(audio_dir, '%(title)s.%(ext)s')
video_title = Path.joinpath(video_dir, '%(title)s.%(ext)s')

batch_dl_file = Path.joinpath(project_home, 'batch_dl.txt')
requirements = Path.joinpath(project_home, 'requirements.txt')

parser = argparse.ArgumentParser(description='A wrapper script to yt-dlp')

parser.add_argument('--batch', '-b', type=bool, help='Perform batch download')

args = parser.parse_args()

def batch_convert():
    format = str(input('Audio or Video?: ')).lower()

    match format:
        case "audio":
            run(['yt-dlp', '-x', '-f', 'ba', '--audio-format', 'mp3', '-o', f'{audio_title}', '-a', f'{batch_dl_file}'])
        case "video":
            run(['yt-dlp', '-f', 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b', '--sponsorblock-remove', 'sponsor,selfpromo,interaction', '-o', f'{video_title}', '-a', f'{batch_dl_file}'])
        case _:
            print("Response must be 'Audio' or 'Video'!")

def normal_convert():
    downloads_complete = False
    while downloads_complete != True: # type: ignore
        format = str(input('Audio or Video?: ')).lower()

        url = str(input('Enter URL here: '))

        val = False

        match format:
            case "audio":
                run(['yt-dlp', '-x', '-f', 'ba', '--audio-format', 'mp3', '-o', f'{audio_title}', f'{url}'])   
                while val != True:
                    do_continue = str(input("Do you want to convert another file? (y/n): ")).lower()
                    match do_continue:
                        case "y":
                            val = True
                        case "n":
                            downloads_complete = True
                            val = True
                        case _:
                            print("Answer must be Y or N!")
            case "video":
                run(['yt-dlp', '-f', 'bv*[ext=mkv]+ba[ext=m4a]/b[ext=mkv] / bv*+ba/b', '--sponsorblock-remove', 'sponsor,selfpromo,interaction', '-o', f'{video_title}', f'{url}'])
                while val != True:
                    do_continue = str(input("Do you want to convert another file? (y/n): ")).lower()
                    match do_continue:
                        case "y":
                            val = True
                        case "n":
                            downloads_complete = True
                            val = True
                        case _:
                            print("Answer must be Y or N!")
            case _:
                print("Response must be 'Audio' or 'Video'!")

run(['pip', 'install', '--update', '-r', f'{requirements}'])

if not audio_dir.exists():
    audio_dir.mkdir()

if not video_dir.exists():
    video_dir.mkdir()

if args.batch == True:
    batch_convert()
else:
    normal_convert()