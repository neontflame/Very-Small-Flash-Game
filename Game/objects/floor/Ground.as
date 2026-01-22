package objects.floor {
	
	import flash.display.MovieClip;
	import level.Level;
	import flash.events.Event;
	public class Ground extends MovieClip {
		
		public function Ground() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			// constructor code
		}

		function onAddedToStage(event: Event) {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			if (parent is Level) {
				Level(parent).addToGrounds(this);
			}
			if (parent.parent is Level) {
				Level(parent.parent).addToGrounds(this);
			}
		}
	}
	
}
