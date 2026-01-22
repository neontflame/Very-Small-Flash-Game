package objects {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import objects.BaseObject;
	import flash.media.Sound;
	
	import flash.utils.setTimeout;
	
	public class Monitor extends BaseObject {
		var destroyed:Boolean = false;
		
		public function Monitor() {
			super();
			
			params.solid = true;
			stop();
		}
		
		override public function doThingOnce() {
			if (!destroyed) {
				if (player.jumping || player.rolling) {
					giveItem(currentLabel);
					player.velocity.y = -Math.abs(player.velocity.y);
					destroyed = true;
					gotoAndStop('Destroyed');
					
					// sfx
					var sfx:DestroySound = new DestroySound(); 
					sfx.play();
				}
			}
		}
		
		override public function loop() {
			super.loop();
			
			if (player.rolling || player.jumping || destroyed) {
				params.solid = false;
			} else {
				params.solid = true;
			}
		}
		
		function giveItem(item:String) {
			
		}
	}
	
}
