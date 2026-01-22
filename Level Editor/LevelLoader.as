package 
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;

	public class LevelLoader
	{
		public static var levelXml:XML;
		// var xmlLoader = new URLLoader();
		
		public function LevelLoader()
		{
			// xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded);
			// xmlLoader.load(new URLRequest("scores.xml"));
		}
		
		public static function loadXmlToLevel(xmlData:String, lvl:CoolLevel)
		{
			trace("Clearing level...");
			lvl.clearAll();
			
			trace("Loading XML onto LevelLoader...");
			levelXml = new XML(xmlData);
			// trace(levelXml.toXMLString()); 
			
			for each (var chunk:XML in levelXml.chunks.chunk) {
				trace('Chunk level: ' + chunk.attribute("lvl") + 
					  ' | Type: ' + chunk.attribute("type") + 
					  ' | X: ' + chunk.attribute("x") + 
					  ' | Y: ' + chunk.attribute("y"));
					  
				lvl.addChunk(Number(chunk.attribute("x")), Number(chunk.attribute("y")), int(chunk.attribute("type")));
			}
			
			for each (var obj:XML in levelXml.objects.object) {
				trace('Object: ' + obj.attribute("obj") + 
					  ' | X: ' + obj.attribute("x") + 
					  ' | Y: ' + obj.attribute("y"));
					  
				lvl.addObject(Number(obj.attribute("x")), Number(obj.attribute("y")), obj.attribute("obj"));
			}
			
			trace("Loaded!");
		}
		
		public static function saveLevelToXml(lvl:CoolLevel):XML
		{
			trace("Saving level to XML...");
			levelXml = new XML('<?xml version="1.0" encoding="UTF-8" ?><level><chunks></chunks><objects></objects></level>');
			
			for each(var chunk in lvl.chunks) {
				var chunkXml:XML = <chunk/>;
				chunkXml.@lvl = "GHZ";
				chunkXml.@type = chunk.currentFrame;
				chunkXml.@x = chunk.x;
				chunkXml.@y = chunk.y;
				levelXml.chunks.appendChild(chunkXml);
			}
			for each(var obj in lvl.objects) {
				var objectXml:XML = <object/>;
				objectXml.@x = obj.x;
				objectXml.@y = obj.y;
				objectXml.@obj = obj.currentLabel;
				levelXml.objects.appendChild(objectXml);
			}
			
			trace(levelXml.toXMLString());
			return levelXml;
		}
	}

}