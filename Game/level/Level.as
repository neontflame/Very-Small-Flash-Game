package level {
	import flash.display.MovieClip;
	
	import flash.geom.Point;
	
	import objects.BaseObject;
	import objects.*;
	import objects.floor.*;
	import objects.player.*;
	import level.Chunk;
	
	public class Level extends MovieClip {
		public var chunks:Vector.<Chunk>;
		public var ojects:Array = [];
		
		public var grounds:Vector.<Ground>;
		public var jumpthrus:Vector.<Jumpthru>;
		public var solids:Vector.<BaseObject>;
		public var ply:Player = null;
		public var spawn:Spawnpoint;
		
		public function Level() {
			// idfk lol
			chunks = new Vector.<Chunk>();
			ojects = new Array();
		}

		public function addChunk(xPos:Number = 0, yPos:Number = 0, current:Number = 0) {
			if (chunks == null) chunks = new Vector.<Chunk>();
			
			var pos:Point = new Point(xPos, yPos);
			
			var chunk:Chunk = new Chunk();
			chunk.x = pos.x;
			chunk.y = pos.y;
			chunk.gotoAndStop(current);
			chunks.push(chunk);
			addChild(chunk);
			
			trace('Chunk: ' + current + 
					  ' | X: ' + xPos + 
					  ' | Y: ' + yPos);
		}

		public function addObject(xPos:Number = 0, yPos:Number = 0, current:String = "") {
			if (ojects == null) ojects = new Array();
			
			var pos:Point = new Point(xPos, yPos);
			
			if (current != "Spawnpoint") {
				var object:BaseObject = new BaseObject();
				
				switch (current) {
					case "Ring":
						object = new Ring();
						break;
					case "1up Monitor":
						object = new Monitor();
						object.gotoAndStop('Life');
						break;
					case "Ring Monitor":
						object = new Monitor();
						object.gotoAndStop('Ring');
						break;
					case "Shield Monitor":
						object = new Monitor();
						object.gotoAndStop('Shield');
						break;
					case "Invincibility Monitor":
						object = new Monitor();
						object.gotoAndStop('Invincibility');
						break;
					case "Checkpoint":
						object = new Checkpoint();
						break;
				}
				object.x = pos.x;
				object.y = pos.y;
				ojects.push(object);
				// object.gotoAndStop(current);
				addChild(object);
			} else {
				spawn = new Spawnpoint();
				spawn.x = pos.x;
				spawn.y = pos.y;
				addChild(spawn);
			}
			
			trace('Object: ' + current + 
					  ' | X: ' + xPos + 
					  ' | Y: ' + yPos);
					  
			if (object) return object;
			if (spawn) return spawn;
		}
		
		public function addToGrounds(gr:Ground) {
			if (grounds == null) grounds = new Vector.<Ground>();
			grounds.push(gr);
		}
		public function addToJumpthrus(jt) {
			if (jumpthrus == null) jumpthrus = new Vector.<Jumpthru>();
			jumpthrus.push(jt);
		}
		public function addToSolids(obj:BaseObject) {
			if (solids == null) solids = new Vector.<BaseObject>();
			solids.push(obj);
		}
		public function setPlayer(pl:Player) {
			ply = pl;
		}
		
		public function clearAll() {
			for each(var chunk in chunks) {
				chunks.splice(chunks.indexOf(chunk), 1);
			}
			for each(var obj in ojects) {
				ojects.splice(ojects.indexOf(obj), 1);
			}
			
			chunks = new Vector.<Chunk>();
			ojects = new Array();
			grounds = new Vector.<Ground>();
			jumpthrus = new Vector.<Jumpthru>();
			solids = new Vector.<BaseObject>();
			
			for (var i = 0; i < numChildren; i++) {
				if (getChildAt(i) is BaseObject) {
					BaseObject(getChildAt(i)).removeEventListeners();
				}
			}
			removeChildren();
			x = 0;
			y = 0;
		}
	}
}