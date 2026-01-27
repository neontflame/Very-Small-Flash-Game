package  {
	import flash.media.SoundChannel;
	import flash.media.Sound;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	
	public class MusicPlayer {
		public static var musicChannel:SoundChannel;
		static var currentMusic:String = '';
		
		public static var sfxChannel:SoundChannel;
		
		public function MusicPlayer() {
			// constructor code
		}

		public static function playMusic(musicName:String, forceStop:Boolean = false) {
			if (musicChannel == null) 
				musicChannel = new SoundChannel();
			
			var musReference:Class = getDefinitionByName(musicName) as Class;
			
			if (forceStop) {
				musicChannel.stop();
				currentMusic = '';
			}
			
			if (currentMusic != musicName) {
				musicChannel.stop();
				currentMusic = musicName;
				musicChannel = new musReference().play(0, 9999);
			}
		}


		public static function playSfx(sfxName:String, forceStop:Boolean = false) {
			if (sfxChannel == null) 
				sfxChannel = new SoundChannel();
			
			var sfxReference:Class = getDefinitionByName(sfxName) as Class;
			
			if (forceStop) {
				sfxChannel.stop();
			}
			
			sfxChannel = new sfxReference().play();
		}
	}
	
}
