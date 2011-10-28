import display.spriteloader.event.SpriteMapEvent;
import display.spriteloader.SpriteMap;
import display.spriteloader.SpriteSettings;
import mx.utils.Delegate;
/**
 * ...
 * @author 
 */
class display.spriteloader.Sprite extends MovieClip {

	//used to register this class as though it was in the Library
	private static var symbolName:String = "__Packages.display.spriteloader.Sprite";
	private static var symbolOwner:Function = Sprite;
	private static var symbolLinked = Object.registerClass(symbolName, symbolOwner);
	private var _size:Number = 20;
	private var _spriteMap:SpriteMap;
	private var _mapOffsetX:Number = 0;
	private var _mapOffsetY:Number = 0;
	private var _mapAreaWidth:Number = 0;
	private var _mapAreaHeight:Number = 0;
	private var thisObj = this;
	

	public function Sprite() 
	{
			thisObj = this;
	}
	
	public static function create(spriteMap:SpriteMap, target:MovieClip,instanceName:String,settings:SpriteSettings,depth:Number):Sprite
	{
		var params:Object = (settings instanceof SpriteSettings) ? settings : new SpriteSettings();
		params.spriteMap = spriteMap;
		if (depth == undefined) depth = target.getNextHighestDepth();
		var ico:Sprite = Sprite(target.attachMovie(symbolName, instanceName, depth, params));
		if (!spriteMap.loaded) {
			spriteMap.addEventListener(SpriteMapEvent.LOAD_COMPLETE, function(){ico.draw()}); // wrapped in function to keep the this-context on draw()
		}else {
			ico.draw();
		}
		return ico;
	}
	
	
	public function draw()
	{
		trace("draw!")
		this.attachBitmap(spriteMap.bitmapData, _root.getNextHighestDepth());// make area
		/*this.clear();
		this.lineStyle(2, 0xFF0000, 100, true);
		this.moveTo(0, 0);
		this.lineTo(0, size);
		this.lineTo(size, size);
		this.lineTo(size, 0);
		this.lineTo(0, 0);*/
	}
	
	
	public function get spriteMap():SpriteMap 
	{
		return _spriteMap;
	}
	public function set spriteMap(value:SpriteMap):Void 
	{
		if (!_spriteMap) {
			_spriteMap = value;
		}else {
			trace('SpriteIcon:set spriteMap() is not accessible');
		}
		
	}
	public function get mapOffsetX():Number 
	{
		return _mapOffsetX;
	}
	public function set mapOffsetX(value:Number):Void 
	{
		trace('SpriteIcon:mapOffsetX');
		_mapOffsetX = value;
	}
	public function get mapOffsetY():Number 
	{
		return _mapOffsetY;
	}
	public function set mapOffsetY(value:Number):Void 
	{
		_mapOffsetY = value;
	}
	public function get mapAreaWidth():Number 
	{
		return _mapAreaWidth;
	}
	public function set mapAreaWidth(value:Number):Void 
	{
		_mapAreaWidth = value;
	}
	public function get mapAreaHeight():Number 
	{
		return _mapAreaHeight;
	}
	public function set mapAreaHeight(value:Number):Void 
	{
		_mapAreaHeight = value;
	}
	
	

}