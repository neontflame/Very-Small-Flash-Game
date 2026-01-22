package objects.player {
    import flash.display.MovieClip;
    import flash.events.Event;
    
	import flash.ui.Keyboard;
	
    public class FlyingPlayer extends Player {
        private var flightPower:Number = 0.5;
        private var maxFlightSpeed:Number = 5;
        private var isFlying:Boolean = false;
        
        public function FlyingPlayer() {
            super();
            
            // Disable gravity for flying
            params.gravForce = 0.9;
        }
        
        override public function getMoving() {
            // Custom movement for flying
			if (!floorCheck(2)) { 
				if (keyPressed[Keyboard.UP]) {
					velocity.y -= flightPower;
					isFlying = true;
				}
				if (keyPressed[Keyboard.DOWN]) {
					velocity.y += flightPower;
					isFlying = true;
				}
			}
            
            // Horizontal movement (keep parent behavior)
            super.getMoving();
            
            // Limit flight speed
			if (isFlying) {
				if (Math.abs(velocity.y) > maxFlightSpeed) {
					velocity.y = maxFlightSpeed * (velocity.y > 0 ? 1 : -1);
				}
			}
        }
        
        override public function getAnimating() {
            if (isFlying) {
                plysprite.gotoAndStop("jump");
                isFlying = false;
            } else {
                super.getAnimating();
            }
        }
    }
}