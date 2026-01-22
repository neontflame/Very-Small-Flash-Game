package objects.player {
	import flash.display.MovieClip;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import flash.geom.Point;
	
	import flash.media.SoundChannel;
	
	import flash.ui.Keyboard;
	
	import utils.*;
	
	import level.Level;
	import objects.player.sprites.*;
	import objects.player.effects.*;
	import flash.display.BlendMode;
	
	public class Player extends MovieClip {
		public var params:Object = {
			width: 24,
			height: 48,
			jumpForce: 7.5,
			gravForce: 0.375,
			friction: 0.93,
			rollFriction: 0.995,
			horizontalAccelG: 0.465,
			horizontalAccelA: 0.3875,
			maxSpeed: 9,
			maxHardSpeed: 24,
			slopeVelCoefficient: 0.35,
			slopeRollCoefficient: 0.8
		}

		public var animThreshold:Object = {
			run: 7.45,
			sprint: 13
		}
		
		
		// misc shit do not fuck around with!
		public var rings:Number = 0;
		
		public var velocity:Point = new Point(0, 0);
		var _lvl:Level;
		var kowot_frames:Number = 0;
		var horizAccel:Number = 0;
		var gravityAngle:Number = 90;
		var gravSin = Math.sin(gravityAngle * Math.PI/180);
		var gravCos = Math.sin(gravityAngle * Math.PI/180);
		public var jumping:Boolean = false;
		var holding_jump:Boolean = false;
		public var rolling:Boolean = false;
		
		public var healthState:Number = 0; // 0 is normal, 1 is temporary invince, 2 is post-hurt, 3 is DEAD.
		
		public var invinceTimer:Number = 0; // Bravo Vince.
		public var itemsHeld:Array = []; // shield, shoes, invincibility
		public var shieldType:Number = 0; // 0 normal, 1 bubble, 2 air, 3 fire
		// though this is sonic 1-based so #lol
		
		var renderColls:Boolean = false;
		
		public var rotHelper:MovieClip;
		public var plysprite:MovieClip;
		public var itemEffect:MovieClip;
		
		public var spriteOffsets:Object = {
			scale: 1,
			scaleX: 1,
			scaleY: 1,
			rotation: 0,
			x: 0,
			y: 0
		}
		
		public function Player() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		function onAddedToStage(event: Event) {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			root.addEventListener(Event.ENTER_FRAME, create);
			root.addEventListener(Event.ENTER_FRAME, loop);
			
			// KEYBOARD SHIT!!!! WHAT!!!!
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownH);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpH);
			
			gotoAndStop(2);
			
			createRotHelper();
			createPlySprite();
		}
		
		private function createRotHelper():void {
			rotHelper = new objects.player.RotHelper();
			addChild(rotHelper);
			rotHelper.visible = renderColls;
			rotHelper.rotation = 90;
		}
		
		public function createPlySprite():void {
			plysprite = new SonicSprite();
			addChild(plysprite);
			plysprite.stop();
		}

		public function modifyItemEffect(fx:MovieClip):void {
			if (getChildByName('itemEffect') != null) {
				removeChild(getChildByName('itemEffect'));
			}
			itemEffect = null;
			if (fx == null && itemEffect != null) {
				return;
			}
			
			itemEffect = fx;
			itemEffect.y = -(params.height/2)
			itemEffect.alpha = 0.5;
			itemEffect.blendMode = BlendMode.HARDLIGHT;
			itemEffect.name = "itemEffect";
			addChild(itemEffect);
		}

		public function refreshItemFX() {
			itemEffect = new MovieClip();
			itemEffect.alpha = 0;
			
			if (itemsHeld.indexOf('shield') != -1) {
				modifyItemEffect(new ShieldFX());
			}
			
			if (itemsHeld.indexOf('invincibility') != -1) {
				modifyItemEffect(new InvincibleFX());
				itemEffect.alpha = 1;
			}
		}
		public function create(event: Event): void {
			// Runs once when frame is entered!
			root.removeEventListener(Event.ENTER_FRAME, create);
			// trace('fuck yeahhhhhhhh');
		}
		
		//////////////////////
		// MISC FUNCTIONS!!!
		public var keyPressed: Array = [];

		function keyDownH(e: KeyboardEvent): void {
			keyPressed[e.keyCode] = true;
		} // On key pressed
		function keyUpH(e: KeyboardEvent): void {
			keyPressed[e.keyCode] = false;
		} // On key released
		
		public function setLvl(levl:Level) {
			_lvl = levl;
			_lvl.setPlayer(this);
		}

		// WOAH WALLS AND FLOORS N SHIT WHAAAAAAAAAT
		public function floorCheckType(profund:Number = 0) {
			var floorPoint:Point = new Point(x, y - (params.height/2)); // midpoint
			floorPoint.y += ((params.height/2) + profund) * gravSin;
			floorPoint.x += ((params.height/2) + profund) * gravCos + (velocity.x * gravSin / 2);
			
			if (renderColls) {
				PointRender.renderPoint(floorPoint, {
					color: 0xFF0000,
					size: 2,
					alpha: 0.5,
					duration: 0.02 // Auto-remove after 2 seconds
				});
			}
			
			for each(var col in _lvl.grounds) {
				if (col.hitTestPoint(floorPoint.x, floorPoint.y, true)) {
					return 'ground';
				}
			}
			
			for each(var col in _lvl.jumpthrus) {
				if (col.hitTestPoint(floorPoint.x, floorPoint.y, true) && 
				ceilingCheckJumpthru() != col &&
				wallCheckJumpthru(1) != col &&
				wallCheckJumpthru(-1) != col
				) {
					return 'jumpthru';
				}
			}
			
			for each(var col in _lvl.solids) {
				if (col.hitTestPoint(floorPoint.x, floorPoint.y, true) && col.params.solid) {
					return 'solid';
				}
			}
			return null;
		}
		
		public function floorCheck(profund:Number = 0):Boolean {
			return (floorCheckType(profund) != null ? true : false);
		}

		public function floorCheckSolid(profund:Number = 0) {
			var floorPoint:Point = new Point(x, y - (params.height/2)); // midpoint
			floorPoint.y += ((params.height/2) + profund) * gravSin;
			floorPoint.x += ((params.height/2) + profund) * gravCos + (velocity.x * gravSin / 2);
			
			if (renderColls) {
				PointRender.renderPoint(floorPoint, {
					color: 0xFF00FF,
					size: 2,
					alpha: 0.5,
					duration: 0.02 // Auto-remove after 2 seconds
				});
			}
			
			for each(var col in _lvl.solids) {
				if (col.hitTestPoint(floorPoint.x, floorPoint.y, true) && col.params.solid) {
					return col;
				}
			}
			return null;
		}
		
		public function wallCheck(axis: Number) {
			var paredeDiv:Number = 2;
			
			var wallPoint:Point = new Point(x, y - (params.height/2)); // midpoint
			wallPoint.x += ((params.width / 2) * axis) * gravSin;
			wallPoint.y += ((params.width / 2) * axis) * gravCos;
			
			wallPoint.x += 4 * gravCos;
			wallPoint.y += 4 * gravSin;
			
			if (renderColls) {
				PointRender.renderPoint(wallPoint, {
					color: 0x00FF00,
					size: 2,
					alpha: 0.5,
					duration: 0.02 // Auto-remove after 2 seconds
				});
			}
			
			for each(var col in _lvl.grounds) {
				if (col.hitTestPoint(wallPoint.x, wallPoint.y, true)) {
					return true;
				}
			}
			
			for each(var col in _lvl.solids) {
				if (col.hitTestPoint(wallPoint.x, wallPoint.y, true) && col.params.solid) {
					return true;
				}
			}
			return false;
		}

		public function ceilingCheck() {
			var ceilPoint:Point = new Point(x, y - params.height/2); // midpoint
			ceilPoint.y -= params.height/2 * gravSin;
			ceilPoint.x -= params.height/2 * gravCos;
			
			if (renderColls) {
				PointRender.renderPoint(ceilPoint, {
					color: 0x0000FF,
					size: 2,
					alpha: 0.5,
					duration: 0.02 // Auto-remove after 2 seconds
				});
			}
			for each(var col in _lvl.grounds) {
				if (col.hitTestPoint(ceilPoint.x, ceilPoint.y, true)) {
					return true;
				}
			}
			for each(var col in _lvl.solids) {
				if (col.hitTestPoint(ceilPoint.x, ceilPoint.y, true) && col.params.solid) {
					return true;
				}
			}
			return false;
		}
		
		public function slopeCheck() {
			var slopeDiv:Number = 2.5;
			var slopePoints:Array = [
			new Point(x, y - (params.height/2)), // midpoint
			new Point(x, y - (params.height/2)) // midpoint
			];
			slopePoints[0].y += ((params.height/2) - 2) * gravSin + ((params.width/slopeDiv) * gravCos);
			slopePoints[0].x += ((params.height/2) - 2) * gravCos + ((params.width/slopeDiv) * gravSin);
			
			slopePoints[1].y += ((params.height/2) - 2) * gravSin - ((params.width/slopeDiv) * gravCos);
			slopePoints[1].x += ((params.height/2) - 2) * gravCos - ((params.width/slopeDiv) * gravSin);
			
			
			for each(var floorPoint in slopePoints) {
				if (renderColls) {
					PointRender.renderPoint(floorPoint, {
						color: 0xFFFF00,
						size: 2,
						alpha: 0.5,
						duration: 0.02 // Auto-remove after 2 seconds
					});
				}
			
				for each(var col in _lvl.grounds) {
					if (col.hitTestPoint(floorPoint.x, floorPoint.y, true)) {
						return true;
					}
				}
				
				for each(var col in _lvl.jumpthrus) {
					if (col.hitTestPoint(floorPoint.x, floorPoint.y, true)) {
						return true;
					}
				}
				
				for each(var col in _lvl.solids) {
					if (col.hitTestPoint(floorPoint.x, floorPoint.y, true) && col.params.solid) {
						return true;
					}
				}
			}
			return false;
		}
		
		function ceilingCheckJumpthru() {
			var ceilPoint:Point = new Point(x, y - params.height/2); // midpoint
			ceilPoint.y -= params.height/2 * gravSin;
			ceilPoint.x -= params.height/2 * gravCos;
			
			for each(var col in _lvl.jumpthrus) {
				if (col.hitTestPoint(ceilPoint.x, ceilPoint.y, true)) {
					return col;
				}
			}
			return false;
		}
		
		function wallCheckJumpthru(axis: Number) {
			var paredeDiv:Number = 2;
			
			var wallPoint:Point = new Point(x, y - (params.height/2)); // midpoint
			wallPoint.x += ((params.width / 2) * axis) * gravSin;
			wallPoint.y += ((params.width / 2) * axis) * gravCos;

			for each(var col in _lvl.jumpthrus) {
				if (col.hitTestPoint(wallPoint.x, wallPoint.y, true)) {
					return col;
				}
			}
			return false;
		}
		
		// GRAVITY ANGLE ROTATION FUCKERY
		function positionRotationHelperAngle(xAdd:Number = 0, yAdd:Number = 0, angle:Number = 0):void {
			var sins:Number = Math.sin(angle * Math.PI/180);
			var costs:Number = Math.cos(angle * Math.PI/180);
			
			rotHelper.x = ((params.height/2) * costs) + (xAdd * sins) + (yAdd * costs);
			rotHelper.y = ((params.height/2) * sins) + (xAdd * costs) + (yAdd * sins);
			rotHelper.y -= (params.height/2);
		}
		
		var soloLeveling:Number = 0;
		var maxLeveling:Number = 20;
		
		function getFloorAngle():Number {
			var MAXCHECKDISTANCE:Number = 15;
			var checkResolution:Number = 7;
			
			var coolX:Number = x + rotHelper.x;
			var coolY:Number = y + rotHelper.y;
			var angleInQuestion:Number = rotHelper.rotation;
			
			var sinner:Number = Math.sin(angleInQuestion * Math.PI/180);
			var costly:Number = Math.cos(angleInQuestion * Math.PI/180);
				
			for (var i = 0; i < maxLeveling; i++) {
				if (pontoNoChao(coolX, coolY)) {
					soloLeveling -= 1;
				} else {
					soloLeveling += 1;
				}
				
				if (soloLeveling > maxLeveling) {
					soloLeveling = maxLeveling;
				}
				
				positionRotationHelperAngle(velocity.x * 0.5, soloLeveling, angleInQuestion);
				coolX = x + rotHelper.x;
				coolY = y + rotHelper.y;
			}
							
			positionRotationHelperAngle(velocity.x * 0.5, soloLeveling+1, angleInQuestion);
			coolX = x + rotHelper.x;
			coolY = y + rotHelper.y;
			if (!pontoNoChao(coolX, coolY)) {
				rotHelper.rotation = Cool.angleLerp(rotHelper.rotation, 90, 0.1);
			}
			
			for (var i = 0; i < checkResolution; i++) {
				var edgeSauce:Array = [
					new Point(coolX + (MAXCHECKDISTANCE * sinner), coolY - (MAXCHECKDISTANCE * costly)),
					new Point(coolX - (MAXCHECKDISTANCE * sinner), coolY + (MAXCHECKDISTANCE * costly))
				];
					
				if (pontoPointNoChao(edgeSauce[0])) {
					rotHelper.rotation -= 1;
				}
					
				if (pontoPointNoChao(edgeSauce[1])) {
					rotHelper.rotation += 1;
				}
			}
			
			return rotHelper.rotation;
		}
		
		// pontos no chao
		function pontoPointNoChao(p:Point):Boolean {
			for each(var col in _lvl.grounds) {
				if (col.hitTestPoint(p.x, p.y, true)) {
					return true;
				}
			}
			
			for each(var col in _lvl.jumpthrus) {
				if (col.hitTestPoint(p.x, p.y, true)) {
					return true;
				}
			}
			
			for each(var col in _lvl.solids) {
				if (col.hitTestPoint(p.x, p.y, true)) {
					return true;
				}
			}
			return false;
		}
		
		function pontoNoChao(px:Number, py:Number):Boolean {
			for each(var col in _lvl.grounds) {
				if (col.hitTestPoint(px, py, true)) {
					return true;
				}
			}
			
			for each(var col in _lvl.jumpthrus) {
				if (col.hitTestPoint(px, py, true)) {
					return true;
				}
			}
			
			for each(var col in _lvl.solids) {
				if (col.hitTestPoint(px, py, true)) {
					return true;
				}
			}
			return false;
		}
		// ebd wall floor whatever
		//////////////////////
		
		//////////////////////
		/// sprite coisos
		//////////////////////
		public function spriteUpdate() {
			plysprite.x = spriteOffsets.x;
			plysprite.y = spriteOffsets.y;
			plysprite.rotation = spriteOffsets.rotation;
			plysprite.scaleX = spriteOffsets.scaleX * spriteOffsets.scale;
			plysprite.scaleY = spriteOffsets.scaleY * spriteOffsets.scale;
			
			spriteOffsets.rotation = Cool.angleLerp(spriteOffsets.rotation, gravityAngle-90, 0.2);
			var sins = Math.sin((spriteOffsets.rotation+90) * Math.PI/180);
			var costs = Math.cos((spriteOffsets.rotation+90) * Math.PI/180);
			
			spriteOffsets.x = ((params.height/2) * costs);
			spriteOffsets.y = ((params.height/2) * sins) - (params.height/2);
		}
		//////////////////////
		/// MOVIMENTO O QUE
		//////////////////////
		public function loop(event: Event): void {
			if (healthState != 3) {
				// Runs every time!
				gravSin = Math.floor(Math.sin(gravityAngle * Math.PI/180) * 100)/100;
				gravCos = Math.floor(Math.cos(gravityAngle * Math.PI/180) * 100)/100;
				// trace ('sin: ' + gravSin + ' | cos: ' + gravCos + ' | gravityAngle: ' + gravityAngle);
				if (
				floorCheck(5) &&
				(gravityAngle > -80 || gravityAngle < -160 || Math.abs(velocity.x) > (params.maxSpeed * 0.3))
				) {
					gravityAngle = getFloorAngle();
					var velAdd = rolling ? (params.slopeRollCoefficient * gravCos) : (params.slopeVelCoefficient * gravCos);
					
					if (Math.abs(gravCos) > 0.24) {
						// trace(Math.abs(gravCos));
						velocity.x -= rolling ? (params.slopeRollCoefficient * gravCos) : (params.slopeVelCoefficient * gravCos);
					}
				} else {
					if (gravityAngle != 90) {
						// rampas funcionam agora!
						var prevVelx = (velocity.x * gravSin) + (velocity.y * gravCos);
						var prevVely = (velocity.y * gravSin) - (velocity.x * gravCos);
						
						gravityAngle = 90;
						velocity.x = prevVelx;
						velocity.y = prevVely;
					}
					if (floorCheck(8)) getFloorAngle();
					else rotHelper.rotation = 90;
				}
				
				// accel on ground vs on air
				if (floorCheck(1)) {
					horizAccel = params.horizontalAccelG;
				} else {
					horizAccel = params.horizontalAccelA;
				}
			} else {
				gravityAngle = 90;
				rotHelper.rotation = 90;
			}
			allCollides(gravSin, -gravCos, gravCos, gravSin);
			getAnimating();
			getSfxing();
			getMoving();
			
			for (var i = 0; i < 2; i++) {
				spriteUpdate();
			}
			
			if (velocity.x > params.maxHardSpeed) {
				velocity.x = params.maxHardSpeed;
			}
			if (velocity.x < -params.maxHardSpeed) {
				velocity.x = -params.maxHardSpeed;
			}
		}
		
		function allCollides(xHori, yHori, xVert, yVert) {
			if (healthState != 3) {
				for (var i = 0; i < 2; i++) {
					collideFloor(xVert, yVert);
					collideWall(xHori, yHori);
				}
				collideCeil(xVert, yVert);
			}
			x += velocity.x * xHori;
			x += velocity.y * xVert;
			y += velocity.x * yHori;
			y += velocity.y * yVert;
		}
		
		var ouchies:Boolean = false;
		public function getMoving(){
			if (healthState == 3) {
				velocity.y += params.gravForce;
				return;
			}
			/// oups levou dano
			if (healthState == 2) {
				if (!ouchies) {
					velocity.x = 0;
					ouchies = true;
				}
				velocity.x = -5 * plysprite.scaleX;
				
				if (floorCheck(1)) {
					healthState = 1;
				}
			} else {
				ouchies = false;
				
				if (keyPressed[Keyboard.E]) {
					yowch();
				}
			}
			
			if (itemsHeld.indexOf('invincibility') != -1) {
				if (invinceTimer > 1) {
					invinceTimer -= 1;
				} else {
					itemsHeld.splice(itemsHeld.indexOf('invincibility'), 1);
					refreshItemFX();
				}
			}
			if (healthState == 1) {
				if (invinceTimer > 0) {
					invinceTimer -= 1;
				} else {
					healthState = 0;
				}
			}
			//////////////////////
			//// MOVIMENTO HORIZONTAL
			// se mover pra direita
			if (!rolling) {
				if (keyPressed[Keyboard.RIGHT]) {
					if (velocity.x < params.maxSpeed) { 
						velocity.x += horizAccel;
					}
				}
				// se mover pra esquerda
				else if (keyPressed[Keyboard.LEFT]) {
					if (velocity.x > -params.maxSpeed) { 
						velocity.x -= horizAccel; 
					}
				}
				else {
					// nao se mover
					if (floorCheck(1)) {
						velocity.x = velocity.x * params.friction;
					}
				}
			}
			if (rolling) {
				if (floorCheck(1)) {
					velocity.x = velocity.x * params.rollFriction;
				} else {
					if (keyPressed[Keyboard.RIGHT]) {
						if (velocity.x < params.maxSpeed) { 
							velocity.x += horizAccel * 0.85;
						}
					}
					// se mover pra esquerda
					else if (keyPressed[Keyboard.LEFT]) {
						if (velocity.x > -params.maxSpeed) { 
							velocity.x -= horizAccel * 0.85; 
						}
					}
				}
			}
			
			// girar!
			if (floorCheck(1)) {
				if (keyPressed[Keyboard.DOWN] && Math.abs(velocity.x) > 1) {
					if (!rolling)
						rolling = true;
				}
				
				if (!keyPressed[Keyboard.DOWN] && Math.abs(velocity.x) < 1) {
					if (rolling)
						rolling = false;
				}
			}
			//// ACABA MOVIMENTO HORIZONTAL
			//////////////////////
			//// MOVIMENTO VERTICAL
			//pulo
			if (holding_jump) {
				velocity.y += params.gravForce / 2;
				if (velocity.y >= 0 || !keyPressed[Keyboard.UP]) {
					holding_jump = false;
				}
			} else {
				velocity.y += params.gravForce;
			}
			// coyote frames (kowot mencionado o goat ????)
			if (kowot_frames > 0 && keyPressed[Keyboard.UP]) {
				kowot_frames = 0;
				velocity.y = -params.jumpForce;
				holding_jump = true;
				jumping = true;
				rolling = false;
			}

			// funcionamento de kowot frames
			if (kowot_frames > 0) {
				kowot_frames--;
			}
		}
		
		var isBraking:Boolean = false;
		var sfxChannel:SoundChannel;
		
		public function getSfxing() {
			if (healthState > 2) return;
			if (sfxChannel == null) 
				sfxChannel = new SoundChannel();
				
			if (floorCheck(1)) {
				if (!rolling) {
					if (keyPressed[Keyboard.RIGHT]) {
						if (velocity.x < -1) {
							if (!isBraking) {
								isBraking = true;
								sfxChannel.stop();
								var skidsfx:SkiddingSound = new SkiddingSound();
								sfxChannel = skidsfx.play();
							}
						} else {
							isBraking = false;
						}
					}
						
					if (keyPressed[Keyboard.LEFT]) {
						if (velocity.x > 1) {
							if (!isBraking) {
								isBraking = true;
								sfxChannel.stop();
								var skidsfx:SkiddingSound = new SkiddingSound();
								sfxChannel = skidsfx.play();
							}
						} else {
							isBraking = false;
						}
					}
				}
				if (keyPressed[Keyboard.DOWN] && Math.abs(velocity.x) > 1) {
					if (!rolling) {
						sfxChannel.stop();
						var spinsfx:ChargeSound = new ChargeSound(); 
						sfxChannel = spinsfx.play();
					}
				}
			}
			
			if (kowot_frames > 0 && keyPressed[Keyboard.UP]) {
				// jump sfx
				sfxChannel.stop();
				var jumpsfx:JumpSound = new JumpSound(); 
				sfxChannel = jumpsfx.play();
			}
		}
		
		var playWalkAnim:Boolean = true;
		public function getAnimating() {
			if (healthState != 1) {
				plysprite.alpha = 1;
			}
			if (healthState == 1) {
				plysprite.alpha = 0.5;
			}
			if (healthState == 2) {
				plysprite.gotoAndStop("hurt"); 
				return;
			}
			if (healthState == 3) {
				plysprite.gotoAndStop("death"); 
				return;
			}
			//////////////////////
			//// MOVIMENTO HORIZONTAL
			if (rolling) {
				plysprite.gotoAndStop("roll");
			} else {
				if (Math.abs(velocity.x) > 1 && playWalkAnim && floorCheck(1)) {
					if (Math.abs(velocity.x) > animThreshold.sprint) {
						plysprite.gotoAndStop("sprint");
					}
					else if (Math.abs(velocity.x) > animThreshold.run) {
						plysprite.gotoAndStop("run");
					} else {
						plysprite.gotoAndStop("walk");
					}
				}
				if (keyPressed[Keyboard.RIGHT]) {
					if (!jumping && floorCheck(1)) {
						if (!wallCheck(2)) {
							if (velocity.x > -1) {
								playWalkAnim = true;
								spriteOffsets.scaleX = 1;
							} else {
								playWalkAnim = false;
								plysprite.gotoAndStop("skid");
								spriteOffsets.scaleX = -1;
							}
						}
					}
				} else if (keyPressed[Keyboard.LEFT]) {
					if (!jumping && floorCheck(1)) {
						if (!wallCheck(-2)) {
							if (velocity.x < 1) {
								playWalkAnim = true;
								spriteOffsets.scaleX = -1;
							} else {
								playWalkAnim = false;
								plysprite.gotoAndStop("skid");
								spriteOffsets.scaleX = 1;
							}
						}
					}
				} else {
					// nao se mover
					if ((floorCheckType(1) == 'ground' || floorCheckType(1) == 'jumpthru') && Math.abs(velocity.x) <= 1) {
						plysprite.gotoAndStop("idle");
					}
				}
			}
			//////////////////////
			
			//////////////////////
			//// MOVIMENTO VERTICAL
			// anim de pulo
			if (jumping) {
				plysprite.gotoAndStop("jump");
			/*
				if (velocity.y > 0 && !floorCheck(2)) {
					plysprite.gotoAndStop("fall");
					if (plysprite.spr.currentFrame == plysprite.spr.totalFrames) 
						plysprite.spr.gotoAndPlay(3);
				} else {
					plysprite.gotoAndStop("jump");
				}
			*/
			}
		}
		
		function yowch(forceDeath:Boolean = false) {
			if (healthState < 1) {
				if (!forceDeath) {
					if (rings > 0 || itemsHeld.indexOf('shield') != -1) {
						jumping = false;
						velocity.y = -7;
						healthState = 2;
						invinceTimer = 120;
					}
					
					if (itemsHeld.indexOf('shield') != -1) {
						// Shield Loster
						sfxChannel.stop();
						var hurtsfx:HurtSound = new HurtSound(); 
						sfxChannel = hurtsfx.play();
						
						itemsHeld.splice(itemsHeld.indexOf('shield'), 1);
						refreshItemFX();
					} else if (rings > 0) {
						// Ring Loster
						sfxChannel.stop();
						var loseringssfx:LoseRingsSound = new LoseRingsSound(); 
						sfxChannel = loseringssfx.play();
											
						var posOfEvil = new Point(x - _lvl.x, (y - params.height/2) - _lvl.y - 32);
						
						for (var ringLost = 0; ringLost < rings; ringLost++) {
							var coolAngle = ((180 / rings) * ringLost) - 90;
							var coolSin = Math.sin(Cool.degToRad(coolAngle));
							var coolCos = Math.cos(Cool.degToRad(coolAngle));
							trace ('ring ' + ringLost + ' : ' + coolAngle + ' | sin: ' + coolSin + ' | cos: ' + coolCos);
							
							var ring = _lvl.addObject(posOfEvil.x, posOfEvil.y, 'Ring');
							ring.x = posOfEvil.x;
							ring.y = posOfEvil.y;
							ring.params.hasPhysics = true;
							ring.params.bouncy = true;
							ring.velocity.x = 3 * coolSin;
							ring.velocity.y = -3 * coolCos;
						}
						rings = 0;
					} else {
						// Life Loster
						sfxChannel.stop();
						var hurtsfx:HurtSound = new HurtSound(); 
						sfxChannel = hurtsfx.play();
						
						jumping = false;
						gravityAngle = 90;
						velocity.y = -7;
						healthState = 3;
						PlayerStats.lives -= 1;
						TimeTracker.stopTimer();
					}
				}
			}
			
			if (forceDeath) {
				sfxChannel.stop();
				var hurtsfx:HurtSound = new HurtSound(); 
				sfxChannel = hurtsfx.play();
					
				jumping = false;
				gravityAngle = 90;
				velocity.y = -7;
				healthState = 3;
				PlayerStats.lives -= 1;
				TimeTracker.stopTimer();
			}
		}
		
		//////////////////////
		// COLISOES DESSA VEZ DE VERDADE
		// colisao com o chao
		function collideFloor(xVert, yVert) {
			if (velocity.y > 0 && floorCheck(1)) { // colisao com o chao
				velocity.y = 1;
				jumping = false;
				kowot_frames = 8; // 60fps
				
				for (var i = 0; i < 15; i++) {
					if (!floorCheck()) break;
					y -= 1 * yVert;
					x -= 1 * xVert;
				}
			}
		}
		
		// colisao com a parede
		function collideWall(xHori, yHori) {
			for (var i = 0; i < 20; i++) {
				while (wallCheck(1)) {
					velocity.x = 0;
					x -= 1 * xHori;
					y -= 1 * yHori;
					rolling = false;
				}
				while (wallCheck(-1)) {
					velocity.x = 0;
					x += 1 * xHori;
					y += 1 * yHori;
					rolling = false;
				}
			}
		}
		// colisao com o teto
		function collideCeil(xVert, yVert){
			while (velocity.y < 0 && ceilingCheck()) {
				velocity.y = 0;
				y += 1 * yVert;
				x += 1 * xVert;
			}
		}
		//////////////////////
		
	}
	
}
