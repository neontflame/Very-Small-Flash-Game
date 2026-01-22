package utils {
	import flash.geom.Point;
	import flash.display.MovieClip;
	
	public class Cool {
		public function Cool() {
			trace('cool utils!');
		}
		public static function lerp(x:Number, y:Number, s:Number):Number
		{
			 return x*(1-s) + y*s;
		}
		
		public static function angleLerp(a:Number, b:Number, lerpFactor:Number):Number // Lerps from angle a to b (both between 0.f and 360.f), taking the shortest path
		{
			var result:Number;
			var diff:Number = b - a;
			
			if (diff < -180)
			{
				// lerp upwards past 360
				b += 360;
				result = lerp(a, b, lerpFactor);
				if (result >= 360)
				{
					result -= 360;
				}
			}
			else if (diff > 180)
			{
				// lerp downwards past 0
				b -= 360;
				result = lerp(a, b, lerpFactor);
				if (result < 0)
				{
					result += 360;
				}
			}
			else
			{
				// straight lerp
				result = lerp(a, b, lerpFactor);
			}

			return result;
		}

		public static function degToRad(degrees:Number):Number {
			return degrees * Math.PI/180;
		}
		public static function radToDeg(radians:Number):Number {
			return radians * 180/Math.PI;
		}
		
		public static function sign(num:Number):Number {
			if (num > 0) return 1;
			if (num < 0) return -1;
			return 0;
		}
		
		public static function isInRange(angle:Number, start:Number, end:Number):Boolean {
			if (start <= end) {
				return angle >= start && angle <= end;
			} else {
				// Wraps around (e.g., 315 to 45)
				return angle >= start || angle <= end;
			}
		}
		
		public static function zeroPad(number:int, width:int):String {
		   var ret:String = ""+number;
		   while( ret.length < width )
			   ret="0" + ret;
		   return ret;
		}
	}
}
