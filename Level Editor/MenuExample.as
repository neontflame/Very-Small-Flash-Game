package 
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;

	import flash.display.Sprite;
	import flash.display.Stage;

	import flash.events.Event;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.net.FileFilter;

	import flash.ui.Keyboard;

	import EditorProperties;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;

	public class MenuExample extends Sprite
	{
		var fileMenu:NativeMenuItem;
		var editMenu:NativeMenuItem;
		var toolsMenu:NativeMenuItem;
		var chunksMenu:NativeMenuItem;
		var objectsMenu:NativeMenuItem;

		var _stage:Stage;
		var coolLevel:CoolLevel;

		var fileRef:FileReference;
		private var currentFile:File;// Track the currently opened/saved file

		public function MenuExample()
		{
			fileRef = new FileReference();
			fileRef.addEventListener(Event.SELECT, onFileSelected);
			fileRef.addEventListener(Event.CANCEL, onCancel);
			fileRef.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}

		public function doEverything(stage:Stage, _coolLevel:CoolLevel)
		{
			stage.nativeWindow.menu = new NativeMenu();
			// stage.nativeWindow.menu.addEventListener(Event.SELECT, selectCommandMenu);

			fileMenu = stage.nativeWindow.menu.addItem(new NativeMenuItem("File"));
			fileMenu.submenu = createFileMenu();

			editMenu = stage.nativeWindow.menu.addItem(new NativeMenuItem("Edit"));
			editMenu.submenu = createEditMenu();

			toolsMenu = stage.nativeWindow.menu.addItem(new NativeMenuItem("Tools"));
			toolsMenu.submenu = createToolsMenu();

			chunksMenu = stage.nativeWindow.menu.addItem(new NativeMenuItem("Chunks"));
			chunksMenu.submenu = createChunkMenu();

			objectsMenu = stage.nativeWindow.menu.addItem(new NativeMenuItem("Objects"));
			objectsMenu.submenu = createObjectsMenu();

			_stage = stage;
			coolLevel = _coolLevel;
		}

		public function createFileMenu():NativeMenu
		{
			var fileMenu:NativeMenu = new NativeMenu();
			// fileMenu.addEventListener(Event.SELECT, selectCommandMenu);

			var newCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("New"));
			newCommand.addEventListener(Event.SELECT, selectFile);
			newCommand.keyEquivalent = "n";
			newCommand.keyEquivalentModifiers = [Keyboard.CONTROL];

			var openCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Open"));
			openCommand.addEventListener(Event.SELECT, selectFile);
			openCommand.keyEquivalent = "o";
			openCommand.keyEquivalentModifiers = [Keyboard.CONTROL];

			var saveCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Save"));
			saveCommand.addEventListener(Event.SELECT, selectFile);
			saveCommand.keyEquivalent = "s";
			saveCommand.keyEquivalentModifiers = [Keyboard.CONTROL];

			var saveasCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Save as"));
			saveasCommand.addEventListener(Event.SELECT, selectFile);
			saveasCommand.keyEquivalent = "s";
			saveasCommand.keyEquivalentModifiers = [Keyboard.CONTROL,Keyboard.SHIFT];

			fileMenu.addItem(new NativeMenuItem("", true));

			var exit:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Exit"));
			exit.addEventListener(Event.SELECT, selectFile);
			exit.keyEquivalent = "q";
			exit.keyEquivalentModifiers = [Keyboard.CONTROL];

			return fileMenu;
		}

		public function createEditMenu():NativeMenu
		{
			var editMenu:NativeMenu = new NativeMenu();
			// editMenu.addEventListener(Event.SELECT, selectCommandMenu);

			/*
			var copyCommand:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Copy properties"));
			copyCommand.addEventListener(Event.SELECT, selectCommand);
			copyCommand.keyEquivalent = "c";
			
			var pasteCommand:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Paste"));
			pasteCommand.addEventListener(Event.SELECT, selectCommand);
			pasteCommand.keyEquivalent = "v";
			
			editMenu.addItem(new NativeMenuItem("", true));
			*/

			var increaseSnaps:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Increase snap"));
			increaseSnaps.addEventListener(Event.SELECT, selectEdit);
			increaseSnaps.keyEquivalent = "+";
			increaseSnaps.keyEquivalentModifiers = [Keyboard.CONTROL,Keyboard.SHIFT];

			var decreaseSnaps:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Decrease snap"));
			decreaseSnaps.addEventListener(Event.SELECT, selectEdit);
			decreaseSnaps.keyEquivalent = "-";
			decreaseSnaps.keyEquivalentModifiers = [Keyboard.CONTROL,Keyboard.SHIFT];
			
			editMenu.addItem(new NativeMenuItem("", true));

			var metadataCommand:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Edit level metadata"));
			metadataCommand.addEventListener(Event.SELECT, selectEdit);
			metadataCommand.keyEquivalent = "m";
			metadataCommand.keyEquivalentModifiers = [Keyboard.CONTROL,Keyboard.SHIFT];
			
			return editMenu;
		}

		public function createChunkMenu():NativeMenu
		{
			var editMenu:NativeMenu = new NativeMenu();
			// editMenu.addEventListener(Event.SELECT, selectCommandMenu);

			var nextCh:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Next chunk"));
			nextCh.addEventListener(Event.SELECT, selectChunk);
			nextCh.keyEquivalent = "+";
			nextCh.keyEquivalentModifiers = [Keyboard.CONTROL,Keyboard.ALTERNATE];

			var prevCh:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Previous chunk"));
			prevCh.addEventListener(Event.SELECT, selectChunk);
			prevCh.keyEquivalent = "-";
			prevCh.keyEquivalentModifiers = [Keyboard.CONTROL,Keyboard.ALTERNATE];

			return editMenu;
		}

		public function createToolsMenu():NativeMenu
		{
			var editMenu:NativeMenu = new NativeMenu();
			// editMenu.addEventListener(Event.SELECT, selectCommandMenu);

			var selectCommand:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Select"));
			selectCommand.addEventListener(Event.SELECT, selectTool);
			selectCommand.keyEquivalent = "1";
			selectCommand.keyEquivalentModifiers = [Keyboard.SHIFT];

			var placeCommand:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Place"));
			placeCommand.addEventListener(Event.SELECT, selectTool);
			placeCommand.keyEquivalent = "2";
			placeCommand.keyEquivalentModifiers = [Keyboard.SHIFT];

			var eraseCommand:NativeMenuItem = editMenu.addItem(new NativeMenuItem("Erase"));
			eraseCommand.addEventListener(Event.SELECT, selectTool);
			eraseCommand.keyEquivalent = "3";
			eraseCommand.keyEquivalentModifiers = [Keyboard.SHIFT];

			return editMenu;
		}

		var objList:Array = ["Ring", "Checkpoint",
							"",
							"1up Monitor", "Ring Monitor", "Shield Monitor", "Invincibility Monitor", 
							"",
							"Motobug","Chopper", "Buzz Bomber", "Crabmeat", 
							"",
							"Spawnpoint", "Death Limit"];
		public function createObjectsMenu():NativeMenu
		{
			var editMenu:NativeMenu = new NativeMenu();
			// editMenu.addEventListener(Event.SELECT, selectCommandMenu);

			for (var obj in objList)
			{
				if (objList[obj] == "")
				{
					editMenu.addItem(new NativeMenuItem("", true));
				}
				else
				{
					var objectItem:NativeMenuItem = editMenu.addItem(new NativeMenuItem(objList[obj]));
					objectItem.addEventListener(Event.SELECT, selectObject);
				}
			}

			return editMenu;
		}

		private function selectCommand(event:Event):void
		{
			trace("Selected command: " + event.target.label);
		}

		private function selectCommandMenu(event:Event):void
		{
			if (event.currentTarget.parent != null)
			{
				var menuItem:NativeMenuItem =
				findItemForMenu(NativeMenu(event.currentTarget));
				if (menuItem != null)
				{
					trace("Select event for \"" +
					event.target.label +
					"\" command handled by menu: " +
					menuItem.label);
				}
			}
			else
			{
				trace("Select event for \"" +
				event.target.label +
				"\" command handled by root menu.");
			}
		}

		private function findItemForMenu(menu:NativeMenu):NativeMenuItem
		{
			for each (var item:NativeMenuItem in menu.parent.items)
			{
				if (item != null)
				{
					if (item.submenu == menu)
					{
						return item;
					}
				}
			}
			return null;
		}

		// File
		var lvlFilter:FileFilter = new FileFilter("Level (*.xml)","*.xml");

		private function selectFile(event:Event):void
		{
			trace('file: ' + event.target.label);
			switch (event.target.label)
			{
				case "New":
					coolLevel.clearAll();
					EditorProperties.reset();
					currentFile = null;// Clear current file reference
					
					_stage.nativeWindow.title = "lvEdit - New level";
					break;

				case "Open":
					fileRef.browse([lvlFilter]);
					break;

				case "Save" :
					saveFile(false);// Save to current file or prompt if none
					break;

				case "Save as" :
					saveFile(true);// Always prompt for file location
					break;

				case "Exit" :
					NativeApplication.nativeApplication.exit();
					break;
			}
		}

		private function saveFile(forceSaveAs:Boolean = false):void
		{
			// Generate XML from level
			var xmlData:XML = LevelLoader.saveLevelToXml(coolLevel);
			var xmlString:String = xmlData.toXMLString();

			// If we have a current file and not forcing Save As, save to it
			if (! forceSaveAs && currentFile != null)
			{
				saveToFile(currentFile, xmlString);
			}
			else
			{
				// Otherwise, prompt for file location
				var file:File = new File();
				file.addEventListener(Event.SELECT, function(evt:Event):void {
				currentFile = file; // Remember the file for future saves
				saveToFile(file, xmlString);
				});

				file.browseForSave("Save level");
			}
		}

		private function saveToFile(file:File, xmlString:String):void
		{
			try
			{
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeUTFBytes(xmlString);
				fileStream.close();

				_stage.nativeWindow.title = "lvEdit - " + file.nativePath;
				trace("Level saved successfully to: " + file.nativePath);
			}
			catch (error:Error)
			{
				trace("Error saving file: " + error.message);
			}
		}

		private function loadFromFile(file:File):void
		{
			try
			{
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				var xmlString:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
				fileStream.close();
				
				LevelLoader.loadXmlToLevel(xmlString, coolLevel);
				currentFile = file;// Remember the opened file
				
				_stage.nativeWindow.title = "lvEdit - " + file.nativePath;
				trace("Level loaded successfully from: " + file.nativePath);
			}
			catch (error:Error)
			{
				trace("Error loading file: " + error.message);
			}
		}

		public function onFileSelected(evt:Event):void
		{
			fileRef.addEventListener(ProgressEvent.PROGRESS, onProgress);
			fileRef.addEventListener(Event.COMPLETE, onComplete);
			fileRef.load();
		}

		public function onProgress(evt:ProgressEvent):void
		{
			trace("Loaded " + evt.bytesLoaded + " of " + evt.bytesTotal + " bytes.");
		}

		public function onComplete(evt:Event):void
		{
			trace("File was successfully loaded.");
				_stage.nativeWindow.title = "lvEdit - " + fileRef.name;
			LevelLoader.loadXmlToLevel(fileRef.data.toString(), coolLevel);

			// Note: FileReference doesn't give us the actual File object
			// So currentFile won't be set when loading via FileReference
			// Consider switching to File class for both open and save
		}

		public function onCancel(evt:Event):void
		{
			trace("The browse request was canceled by the user.");
		}

		public function onIOError(evt:IOErrorEvent):void
		{
			trace("There was an IO Error.");
		}

		// Edit
		private function selectEdit(event:Event):void
		{
			trace('edit: ' + event.target.label);
			switch (event.target.label)
			{
				case "Edit level metadata":
					EditorProperties.changeTool('Metadata');
					break;
				case "Increase snap" :
					EditorProperties.incSnap();
					break;
				case "Decrease snap" :
					EditorProperties.decSnap();
					break;
			}
		}

		// Tools
		private function selectTool(event:Event):void
		{
			trace('tool: ' + event.target.label);
			EditorProperties.changeTool(event.target.label);
		}

		// Chunk;
		private function selectChunk(event:Event):void
		{
			switch (event.target.label)
			{
				case "Next chunk" :
					EditorProperties.incChunk();
					break;
				case "Previous chunk" :
					EditorProperties.decChunk();
					break;
			}
		}

		// Object
		private function selectObject(event:Event):void
		{
			trace('obj: ' + event.target.label);
			EditorProperties.changeObject(event.target.label);
		}
	}
}