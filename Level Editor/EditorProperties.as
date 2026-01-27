package  {
	import flash.utils.getQualifiedClassName;
	import flash.display.MovieClip;
	
	public class EditorProperties {
		public static var coolLvl:CoolLevel;
		
		public static var metadataEditor:MovieClip;
		
		public static var snapping:Number = 32;
		public static var curChunk:Number = 1;
		public static var curObject:String = "Ring";
		public static var curTool:String = "Select";
		public static var curSubtool:String = "chunk";
		
		public static var loadingLevel:Boolean = false;
		
		public function EditorProperties() {
			// constructor code
		}
		
		public static function incSnap(){
			snapping *= 2;
		}
		
		public static function decSnap(){
			if (snapping > 1)
				snapping /= 2;
		}

		public static function changeTool(tool:String = "") {
			curTool = tool;
		}
		public static function changeSubtool(tool:String = "") {
			curSubtool = tool;
		}
		public static function changeObject(obj:String = "") {
			curObject = obj;
			changeSubtool('object');
		}

		public static function setMetadataEditor(edit:MovieClip) {
			metadataEditor = edit;
		}
		
		public static function incChunk(){
			curChunk += 1;
			
			changeSubtool('chunk');
		}
		
		public static function decChunk(){
			if (curChunk > 1)
				curChunk -= 1;
				
			changeSubtool('chunk');
		}
		
		public static function copyProps() {
			if (coolLvl != null) {
				if (coolLvl.selectedThing != null) {
					if (getQualifiedClassName(coolLvl.selectedThing) == "Chunk") {
						curChunk = coolLvl.selectedThing.currentFrame + 1;
						changeSubtool('chunk');
						trace(coolLvl.selectedThing.currentFrame);
					}
					if (getQualifiedClassName(coolLvl.selectedThing) == "CoolObject") {
						changeObject(coolLvl.selectedThing.currentLabel);
					}
				}
			}
		}
		
		public static function reset(){		
			snapping = 32;
			curChunk = 1;
			curObject = "Ring";
			curTool = "Select";
			curSubtool = "chunk";
		}
		// ends here
	}
	
}
