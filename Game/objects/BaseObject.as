package objects {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	import level.Level;
	
	import objects.player.Player;
	
	public class BaseObject extends MovieClip {
		public var parentLevel:Level;
		public var player:Player = null;
		
		public var params:Object = {
			solid: false,
			hasPhysics: false,
			bouncy: false,
			bounceMult: 0.7,
			gravForce: 0.375,
			width: 0,
			height: 0,
			canBeUsed: true,
			hitFromAbove: false
		}
		
		public var solid:Boolean = true;
		
		public var velocity:Point = new Point(1,0);
		
		var touchedPlayer:Boolean = false;
		public var touchedFromAbove:Boolean = false;
		var addedSolid:Boolean = false;
		var levelPos:Point = new Point(0,0);
		
		public function BaseObject() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		function onAddedToStage(event: Event) {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			root.addEventListener(Event.ENTER_FRAME, create);
			root.addEventListener(Event.ENTER_FRAME, technicalLoop);
		}
		
		function create(event: Event): void {
			// Runs once when frame is entered!
			root.removeEventListener(Event.ENTER_FRAME, create);
			if (params.width == 0) params.width = width;
			if (params.height == 0) params.height = height;
		}
		
		public function removeEventListeners() {
			root.removeEventListener(Event.ENTER_FRAME, create);
			root.removeEventListener(Event.ENTER_FRAME, technicalLoop);
		}
		
		public function technicalLoop(event: Event): void {
			if (this.parent == null) {
				return;
			}
			// Runs once when frame is entered!
			if (parentLevel == null) {
				// trace('GET THE PARENT.');
				if (parent is Level) {
					parentLevel = Level(parent);
					levelPos.x = parentLevel.x + 8;
					levelPos.y = parentLevel.y + 20;
				} 
				if (parent.parent is Level) {
					parentLevel = Level(parent.parent);
					levelPos.x = parentLevel.x + 8;
					levelPos.y = parentLevel.y + 20;
				}
			}
			
			if (parentLevel != null) {
				if (parentLevel.ply != null && player == null){
					// trace('GET THE player.');
					player = parentLevel.ply;
				}
				
				if (params.solid && !addedSolid) {
					addedSolid = true;
					trace('Add Solid');
					parentLevel.addToSolids(this);
				}
				
				if (params.hasPhysics) {
					doPhysixShit();
				}
				
				loop();
			}
		}

		public function loop() {
			if (player != null) {
				if (hitTestObject(player.plysprite) && params.canBeUsed) {
					touchedFromAbove = false;
					doThing();
					doThingOnc();
				} else {
					if (player.floorCheckSolid(2) == this && params.canBeUsed) {
						touchedFromAbove = true;
						doThing();
						doThingOnc();
					} else {
						touchedPlayer = false;
					}
				}
			}
		}
		
		public function doThing() {
			// override this!
			// trace('yeah');
		}
		
		public function doThingOnc() {
			// see This is intentional. It's Meant to Trigger only Once when you touch it
			if (!touchedPlayer) {
				touchedPlayer = true;
				doThingOnce();
			}
		}
		
		public function doThingOnce() {
			// override this!
			trace('yeah (once)');
		}
		
		// ok see now this is gonna be Technical. It's gonna get fucking nutty in this place
		function doPhysixShit() {
			if (parentLevel == null) return;
			
			velocity.y += params.gravForce;
			
			for (var i = 0; i < 2; i++) {
				collideFloor();
				collideWall();
			}
			collideCeil();
			x += velocity.x;
			y += velocity.y;
		}
		
		// ok entao esses aqui nao vao ter nada de angulo de gravidade
		// isso aqui vai ser o basico do basico eu nao quero etr que perder a cabeça programando RAMPAS denovo
		// eu copiei isso tudo do codigo do sonic #lol
		function floorCheck(profund:Number = 0) {
			var floorPoint:Point = new Point(x, y + profund); 
			floorPoint.x += levelPos.x;
			floorPoint.y += levelPos.y;
			
			for each(var col in parentLevel.grounds) {
				if (col.hitTestPoint(floorPoint.x, floorPoint.y, true)) {
					return true;
				}
			}

			for each(var col in parentLevel.jumpthrus) {
				if (col.hitTestPoint(floorPoint.x, floorPoint.y, true) && 
				ceilingCheckJumpthru() != col &&
				wallCheckJumpthru(1) != col &&
				wallCheckJumpthru(-1) != col
				) {
					return true;
				}
			}
			
			for each(var col in parentLevel.solids) {
				if (col.hitTestPoint(floorPoint.x, floorPoint.y, true) && col != this) {
					return true;
				}
			}
			return false;
		}


		function wallCheck(axis: Number) {
			var wallPoint:Point = new Point(x + ((params.width / 2) * axis), y - (params.height/2));
			wallPoint.x += levelPos.x;
			wallPoint.y += levelPos.y;
			
			for each(var col in parentLevel.grounds) {
				if (col.hitTestPoint(wallPoint.x, wallPoint.y, true)) {
					return true;
				}
			}
			
			for each(var col in parentLevel.solids) {
				if (col.hitTestPoint(wallPoint.x, wallPoint.y, true) && col != this) {
					return true;
				}
			}
			return false;
		}

		function ceilingCheck() {
			var ceilPoint:Point = new Point(x, y - params.height); 
			ceilPoint.x += levelPos.x;
			ceilPoint.y += levelPos.y;
			
			for each(var col in parentLevel.grounds) {
				if (col.hitTestPoint(ceilPoint.x, ceilPoint.y, true)) {
					return true;
				}
			}
			for each(var col in parentLevel.solids) {
				if (col.hitTestPoint(ceilPoint.x, ceilPoint.y, true) && col != this) {
					return true;
				}
			}
			return false;
		}
		
		function ceilingCheckJumpthru() {
			var ceilPoint:Point = new Point(x, y - params.height); 
			ceilPoint.x += levelPos.x;
			ceilPoint.y += levelPos.y;
			
			for each(var col in parentLevel.jumpthrus) {
				if (col.hitTestPoint(ceilPoint.x, ceilPoint.y, true)) {
					return col;
				}
			}
			return false;
		}
		
		function wallCheckJumpthru(axis: Number) {
			var paredeDiv:Number = 2;
			
			var wallPoint:Point = new Point(x + ((params.width / 2) * axis), y - (params.height/2));
			wallPoint.x += levelPos.x;
			wallPoint.y += levelPos.y;

			for each(var col in parentLevel.jumpthrus) {
				if (col.hitTestPoint(wallPoint.x, wallPoint.y, true)) {
					return col;
				}
			}
			return false;
		}
		// cabo checks
		//////////////////////
		// COLISOES O QUE
		// colisao com o chao
		function collideFloor() {
			if (velocity.y > 0 && floorCheck(1)) { // colisao com o chao
				var prevVelocity = -Math.abs(velocity.y) * params.bounceMult;
				
				for (var i = 0; i < 15; i++) {
					if (!floorCheck()) break;
					velocity.y = 1;
					y -= 1;
				}
				
				velocity.y = params.bouncy ? prevVelocity : 0;
			}
		}
		
		// colisao com a parede
		function collideWall() {
			for (var i = 0; i < 15; i++) {
				while (wallCheck(1)) {
					velocity.x = params.bouncy ? -velocity.x : 0;
					x -= 1;
				}
				while (wallCheck(-1)) {
					velocity.x = params.bouncy ? -velocity.x : 0;
					x += 1;
				}
			}
		}
		// colisao com o teto
		function collideCeil(){
			while (velocity.y < 0 && ceilingCheck()) {
				velocity.y = params.bouncy ? Math.abs(velocity.y) * params.bounceMult : 0;
				y += 1;
			}
		}
		//////////////////////
	}
	
}
