package objects {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import objects.BaseObject;
	import flash.media.Sound;
	
	import flash.utils.setTimeout;
	import objects.player.effects.*;
	
	public class Monitor extends BaseObject {
		var destroyed:Boolean = false;
		
		public function Monitor() {
			super();
			
			params.solid = true;
			stop();
		}
		
		override public function doThingOnce() {
			if (!destroyed) {
				if (player.jumping || player.rolling) {
					giveItem(currentLabel);
					player.velocity.y = -Math.abs(player.velocity.y);
					destroyed = true;
					gotoAndStop('Destroyed');
					
					// sfx
					var sfx:DestroySound = new DestroySound(); 
					sfx.play();
				}
			}
		}
		
		override public function loop() {
			super.loop();
			
			if (!player) return;
			
			if (player.rolling || player.jumping) {
				params.solid = false;
			} else {
				params.solid = !destroyed;
			}
		}
		
		function giveItem(item:String) {
			setTimeout(function() {
				switch (item) {
					case 'Life':
						PlayerStats.lives += 1;
						
						var sfx1up:Monitor1UPSound = new Monitor1UPSound(); 
						sfx1up.play();
						break;
					case 'Ring':
						player.rings += 10;
						// sfx
						var sfx:RingSound = new RingSound(); 
						sfx.play();
						break;
					case 'Shield':
						player.itemsHeld.push('shield');
						player.refreshItemFX();
						
						var sfxShield:MonitorShieldSound = new MonitorShieldSound(); 
						sfxShield.play();
						break;
					case 'Invincibility':
						player.itemsHeld.push('invincibility');
						player.refreshItemFX();
						player.invinceTimer = 1380;
						break;
				}
			}, 1000);
		}
	}
	
}
