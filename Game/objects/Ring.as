package objects {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import objects.BaseObject;
	import flash.media.Sound;
	
	public class Ring extends BaseObject {
		var timeoutThing:Number = 256;
		
		public function Ring() {
			super();
		}
		
		override public function doThingOnce() {
			if (player.healthState < 2) {
				player.rings += 1;
				this.parent.removeChild(this);
				x = 10000000;
				y = 10000000;
				
				// sfx
				MusicPlayer.playSfx('RingSound', true);
			}
		}
		
		public function ringTimeout() {
		}
		
		override public function loop() {
			if (this.parent == null) {
				return;
			}
			super.loop();
			
			if (params.hasPhysics) {
				timeoutThing -= 1;
				
				if (timeoutThing < 128) {
					alpha = 0.5
				}
				if (timeoutThing <= 0) {
					this.parent.removeChild(this);
					x = 10000000;
					y = 10000000;
				}
			}
		}
	}
	
}
