package utils {
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.utils.setTimeout;

    public class PointRender {
        public static var debugPoints:Array = [];
        public static var debugContainer:Sprite;
        public static var initialized:Boolean = false;
        
        public function PointRender() {
            // Don't auto-initialize in constructor for static class
        }
        
        // Initialize debug system - call this once at startup
        public static function initDebugRenderer(container:Sprite):void {
            if (debugContainer && debugContainer.parent) {
                debugContainer.parent.removeChild(debugContainer);
            }
            
            debugContainer = new Sprite();
            container.addChild(debugContainer);
            debugContainer.mouseEnabled = false;
            debugContainer.mouseChildren = false;
            debugPoints = [];
            initialized = true;
        }

        public static function renderPoint(point:Point, options:Object = null):void {
            // Auto-initialize with a default if not done yet
            if (!initialized) {
                trace("[PointRender] Warning: Debug renderer not initialized. Call utils.PointRender.initDebugRenderer() first.");
                return;
            }
            
            var color:uint = options && options.color ? options.color : 0xFF0000;
            var size:Number = options && options.size ? options.size : 4;
            var alpha:Number = options && options.alpha ? options.alpha : 0.8;
            var label:String = options && options.label ? options.label : "";
            
            var dot:Sprite = new Sprite();
            
            // Draw point
            dot.graphics.beginFill(color, alpha);
            dot.graphics.drawCircle(0, 0, size);
            dot.graphics.endFill();
            
            dot.x = point.x;
            dot.y = point.y;
            
            debugContainer.addChild(dot);
            debugPoints.push(dot);
            
            // Auto-remove after delay (optional)
            if (options && options.duration) {
                setTimeout(removePoint, options.duration * 1000, dot);
            }
        }

        public static function removePoint(dot:Sprite):void {
            if (debugContainer && debugContainer.contains(dot)) {
                debugContainer.removeChild(dot);
            }
            var index:int = debugPoints.indexOf(dot);
            if (index != -1) debugPoints.splice(index, 1);
        }

        // Clear all debug points
        public static function clearDebugPoints():void {
            if (!debugContainer) return;
            
            while (debugPoints.length > 0) {
                var dot:Sprite = debugPoints.pop();
                if (debugContainer.contains(dot)) {
                    debugContainer.removeChild(dot);
                }
            }
        }

        // Quick one-liner for temporary debugging
        public static function debugPoint(x:Number, y:Number, color:uint = 0xFF0000):void {
            renderPoint(new Point(x, y), {color: color});
        }
    }
}