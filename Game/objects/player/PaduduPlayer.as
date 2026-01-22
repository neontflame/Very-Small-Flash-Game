package objects.player {
    import flash.display.MovieClip;
    import flash.events.Event;
    
	import flash.ui.Keyboard;
	
	import objects.player.sprites.*;
	
    public class PaduduPlayer extends Player {
        
        public function PaduduPlayer() {
            super();
			params = {
				width: 24,
				height: 48,
				jumpForce: 7.5,
				gravForce: 0.375,
				friction: 0.93,
				rollFriction: 0.995,
				horizontalAccelG: 0.465,
				horizontalAccelA: 0.3875,
				maxSpeed: 8,
				maxHardSpeed: 24,
				slopeVelCoefficient: 0.5,
				slopeRollCoefficient: 0.9
			}
        }
        
		override public function createPlySprite():void {
			plysprite = new PaduduSprite();
			addChild(plysprite);
			plysprite.stop();
		}
		
        override public function getMoving() {
            super.getMoving();
        }
        
        override public function getAnimating() {
			if (jumping && plysprite != null) {
				if (velocity.y > 0 && !floorCheck(2)) {
					plysprite.gotoAndStop("fall");
					if (plysprite.spr.currentFrame == plysprite.spr.totalFrames && plysprite.currentLabel == 'fall') 
						plysprite.spr.gotoAndPlay(9);
				} else {
					plysprite.gotoAndStop("jump");
				}
			} else {
				super.getAnimating();
			}
        }
    }
}