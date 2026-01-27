package level
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	import level.Level;

	public class LevelLoader
	{
		public static var levelXml:XML;
		public static var xmlLoader = new URLLoader();
		public static var _lvl:Level;
		public static var isLoaded:Boolean = false;
		
		public function LevelLoader()
		{
			// xmlLoader.load(new URLRequest("scores.xml"));
		}
		
		public static function loadXmlFileToLevel(file:String, lvl:Level) {
			_lvl = lvl;
			isLoaded = false;
			_lvl.clearAll();
			trace('ok try load');
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded);
			xmlLoader.load(new URLRequest(file));
		}
		
		static function xmlLoaded(event:Event) {
			trace('Fuckin nice');
			LevelLoader.loadXmlToLevel(event.target.data, _lvl);
		}
		
		public static function loadXmlToLevel(xmlData:String, lvl:Level)
		{
			trace("Clearing level...");
			lvl.clearAll();
			
			trace("Loading XML onto LevelLoader...");
			levelXml = new XML(xmlData);
			// trace(levelXml.toXMLString()); 

			var meta = levelXml.metadata.data[0];
			
			lvl.lvlFirstName = meta.attribute("name1");
			lvl.lvlSecondName = meta.attribute("name2");
			lvl.lvlAppendix = meta.attribute("appendix");
			lvl.lvlSong = meta.attribute("song");
			
			trace(lvl.lvlFirstName + ' ' + lvl.lvlSecondName + ' Zone, act ' + lvl.lvlAppendix);
			trace('Song played should be ' + lvl.lvlSong);
			
			for each (var chunk:XML in levelXml.chunks.chunk) {
				lvl.addChunk(Number(chunk.attribute("x")), Number(chunk.attribute("y")), int(chunk.attribute("type")));
			}
			
			for each (var obj:XML in levelXml.objects.object) {
				lvl.addObject(Number(obj.attribute("x")), Number(obj.attribute("y")), obj.attribute("obj"));
			}
			
			trace("Loaded!");
			isLoaded = true;
		}
	}

}