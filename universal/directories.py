from pathlib import PurePath,Path

class Directories():
    def __init__(self):
        self.base_dir = Path.cwd()
        self.audio_dir = Path.joinpath(self.base_dir, 'audio')
        self.video_dir = Path.joinpath(self.base_dir, 'video')

    def get_home(self):
        return self.base_dir
    
    def get_audio_dir(self):
        return self.audio_dir
    
    def get_video_dir(self):
        return self.video_dir