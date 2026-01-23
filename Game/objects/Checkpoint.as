package objects {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import objects.BaseObject;
	import flash.media.Sound;
	
	import flash.geom.Point;
	
	public class Checkpoint extends BaseObject {
		var checked:Boolean = false;
		
		public function Checkpoint() {
			super();
		}
		
		override public function doThingOnce() {
			if (!checked) {
				PlayerStats.checkpoint = new Point(player.x, player.y);
				// sfx
				var sfx:CheckpointSound = new CheckpointSound(); 
				sfx.play();
				
				gotoAndStop('Checked');
				checked = true;
			}
		}
	}
	
}
