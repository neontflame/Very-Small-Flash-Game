package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import flash.geom.Point;
	
	import flash.utils.getQualifiedClassName;
	
	import level.Chunk;
	
	public class CoolLevel extends Sprite
	{
		public var chunks:Vector.<Chunk>;
		public var objects:Vector.<CoolObject>;
		public var selectedThing = null;
		public var selectedPos:Point = new Point(0,0);
		
		public function CoolLevel() {
			// constructor code
		}
		
		public function addChunk(xPos:Number = 0, yPos:Number = 0, current:Number = 0) {
			selectedThing = null;
			
			var pos:Point = new Point(xPos * (1/scaleX), yPos * (1/scaleY));
			// pos.x = Math.floor(pos.x);
			// pos.y = Math.floor(pos.y);
			
			if (chunks == null) chunks = new Vector.<Chunk>();
			
			var chunk:Chunk = new Chunk();
			chunk.x = pos.x;
			chunk.y = pos.y;
			chunk.gotoAndStop(current);
			chunks.push(chunk);
			addChild(chunk);
		}

		public function addObject(xPos:Number = 0, yPos:Number = 0, current:String = "") {
			selectedThing = null;
			
			var pos:Point = new Point(xPos * (1/scaleX), yPos * (1/scaleY));
			// var pos:Point = new Point(xPos, yPos);
			
			if (objects == null) objects = new Vector.<CoolObject>();
			
			var object:CoolObject = new CoolObject();
			object.x = pos.x;
			object.y = pos.y;
			object.gotoAndStop(current);
			objects.push(object);
			addChild(object);
		}
		
		public function selectThing(xPoss:Number = 0, yPoss:Number = 0) {
			selectedThing = null;
			var pos:Point = new Point(xPoss, yPoss); // for some reason this is unaffected???????
			// trace('cmon');
			// trace(pos.x, pos.y);
			
			for each(var chunky in chunks) {
				if (chunky.hitTestPoint(pos.x, pos.y, true)) {
					selectedThing = chunky;
					selectedPos = new Point(chunky.x, chunky.y);
					trace(selectedThing);
				}
			}
			
			for each(var objjj in objects) {
				if (objjj.hitTestPoint(pos.x, pos.y, false)) {
					selectedThing = objjj;
					selectedPos = new Point(objjj.x, objjj.y);
					trace(selectedThing);
				}
			}
			
			update();
		}

		public function deleteThing(xPoss:Number = 0, yPoss:Number = 0) {
			selectedThing = null;
			var pos:Point = new Point(xPoss, yPoss);
			// trace('cmon');
			// trace(pos.x, pos.y);
			
			for each(var chunky in chunks) {
				if (chunky.hitTestPoint(pos.x, pos.y, true)) {
					removeChild(chunky);
				}
			}
			
			for each(var objjj in objects) {
				if (objjj.hitTestPoint(pos.x, pos.y, false)) {
					removeChild(objjj);
				}
			}
			
			update();
		}
		public function update() {
			for each(var chunk in chunks) {
				if (chunk) {
					if (selectedThing == chunk) {
						chunk.alpha = 0.5;
					} else if (selectedThing != null) {
						chunk.alpha = 0.75;
					} else {
						chunk.alpha = 1;
					}
				}
			}
			
			for each(var obj in objects) {
				if (obj) {
					if (selectedThing == obj) {
						obj.alpha = 0.5;
					} else if (selectedThing != null) {
						obj.alpha = 0.75;
					} else {
						obj.alpha = 1;
					}
				}
			}
		}
		
		public var posDiffToMouse:Point = new Point(0, 0);
		public var changePosDiff:Boolean = true;
		
		public function selectedIsTouchingPoint(xPoss:Number = 0, yPoss:Number = 0) {
			var pos:Point = new Point(xPoss, yPoss); 
			if (!selectedThing) return false;
			
			if (selectedThing && changePosDiff) {
				posDiffToMouse.x = xPoss - selectedThing.x;
				posDiffToMouse.y = yPoss - selectedThing.y;
			}
			
			if (selectedThing.hitTestPoint(pos.x, pos.y, (getQualifiedClassName(selectedThing) == "Chunk"))) {
				return true;
			}

			return false;
		}
		
		public function clearAll() {
			for each(var chunk in chunks) {
				chunks.splice(chunks.indexOf(chunk), 1);
			}
			for each(var obj in objects) {
				objects.splice(objects.indexOf(obj), 1);
			}
			
			chunks = new Vector.<Chunk>();
			objects = new Vector.<CoolObject>();
			
			removeChildren(); // Ok SO i didnt know you could do this. The more you know
			
			scaleX = 1;
			scaleY = 1;
		}
	}
	
}
