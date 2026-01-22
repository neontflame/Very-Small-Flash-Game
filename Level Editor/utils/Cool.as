package utils {
	
	public class Cool {

		public function Cool() {
			// constructor code
		}
		
		public static function snapNum(num:Number, snap:Number) {
			return Math.floor(num/snap)*snap;
		}
		
		public static function snapNumZoom(num:Number, snap:Number, zoom:Number) {
			return Math.floor(num/(snap * zoom))*(snap * zoom);
		}


	}
	
}
