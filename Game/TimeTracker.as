package  {
	import flash.utils.setInterval;
	import flash.geom.Point;

	public class TimeTracker {
		public static var time:Point = new Point(0, 0);
		static var timeInterval;
		
		public function TimeTracker() {
			// constructor code
		}
		
		public static function startTimer() {
			time.x = 0;
			time.y = 0;
			
			timeInterval = setInterval(function() {
						time.y += 1;
						if (time.y == 60) {
							time.x += 1;
							time.y = 0;
						}
					}, 1000);
		}
		public static function stopTimer() {
			timeInterval = null;
		}
	}
	
}
