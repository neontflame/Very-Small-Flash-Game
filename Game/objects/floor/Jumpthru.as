package objects.floor {
	
	import flash.display.MovieClip;
	import level.Level;
	
	public class Jumpthru extends MovieClip {
		
		public function Jumpthru() {
			// constructor code
			if (parent is Level) {
				Level(parent).addToJumpthrus(this);
			}
			if (parent.parent is Level) {
				Level(parent.parent).addToJumpthrus(this);
			}
		}
	}
	
}
